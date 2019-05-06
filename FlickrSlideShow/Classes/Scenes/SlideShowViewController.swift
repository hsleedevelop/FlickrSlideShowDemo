//
//  SlideShowViewController.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Reachability
import RxReachability
import RxSwiftExt

final class SlideShowViewController: UIViewController {
    static let imageTransitionTime: TimeInterval = 1.0
    // MARK: - * properties --------------------
    var slideShowInterval: TimeInterval!
    var photos: [Photo]!
    
    private var prefetchedPhotos: [Photo] = []
    private var timeChanged: Bool?
    
    private let viewModel = MainViewModel()
    private var disposeBag = DisposeBag()

    private var dispatchQueue = DispatchQueue(label: "io.hsleedevelop.photo.queue", qos: DispatchQoS.background, attributes: .concurrent)
    private var workItems = [String: DispatchWorkItem]()

    private var reachability: Reachability? = Reachability()
    private let fetchNewFeedRelay: PublishRelay<Void> = .init()
    private var timer2dis: Disposable?

    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeSegment: UISegmentedControl! {
        didSet {
            for index in 0..<timeSegment.numberOfSegments {
                timeSegment.setTitle("\(index + 1)s", forSegmentAt: index)
            }
        }
    }
    
    // MARK: - * LifeCycle --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setupRx()
        setupGesture()
        bindViewModel()
        slideShow()
        
        DispatchQueue.main.async { [unowned self] in
            self.timeSegment.selectedSegmentIndex = Int(self.slideShowInterval - 1)
            self.timeSegment.sendActions(for: .valueChanged)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? reachability?.startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        timer2dis?.dispose()
        reachability?.stopNotifier()
    }

    // MARK: - * init & setup --------------------
    private func initUI() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.decelerationRate = .fast
    }
    
    private func setupGesture() {
        let gesture2 = UITapGestureRecognizer() //zoom gesture
        gesture2.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(gesture2)
        
        let gesture1 = UITapGestureRecognizer() //toggle tollbar gesture
        gesture1.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture1)
        
        gesture1.require(toFail: gesture2)
        
        let gestureObs2 = gesture2.rx.event.asObservable()
        let gestureObs1 = gesture1.rx.event.asObservable()
        
        gestureObs1
            .map { [unowned self] _ in !self.controlView.isHidden }
            .do(onNext: { [unowned self] isHidden in
                self.view.backgroundColor = isHidden ? .black : .white
            })
            .bind(to: navigationController!.navigationBar.rx.isHidden, by: disposeBag)
            .bind(to: controlView.rx.isHidden)
            .disposed(by: disposeBag)
        
        gestureObs2
            .subscribe(onNext: { [unowned self] recognizer in
                self.zoom(center: recognizer.location(in: recognizer.view))
            })
            .disposed(by: disposeBag)
    }
    
    private func setupRx() {
        reachability?.rx.isReachable
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] isReachable in
                var message = ""
                if !isReachable {
                    message = "Network is disconnected.\nSlide show will be finished and then slide show will resume if network is connected."
                } else {
                    if self.prefetchedPhotos.count == 0 || self.prefetchedPhotos.count == 0 {
                        self.fetchNewFeedRelay.accept(())
                    }
                    message = "Network is connected.\nResume slide show."
                }
                self.showToast(message, duration: 4.0)
            })
            .disposed(by: disposeBag)
        
        timeSegment.rx.value.asObservable()
            .skip(1)
            .filter { [unowned self] _ in self.photos.count > 0 } //더이상 사진이 없는 경우, 시간 갱신 캔슬
            .bind { [unowned self] value  in
                self.infoLabel.text = "Play each slide for: \(self.timeSegment.titleForSegment(at: value) ?? "")"
                self.slideShowInterval = TimeInterval(value + 1)
                
                self.timeChanged = self.timeChanged == nil ? false : true
            }
            .disposed(by: disposeBag)
    }
    
    ///이미지 프리패치
    private func generateWorkItem(_ photo: Photo) -> DispatchWorkItem {
        return DispatchWorkItem { [weak self] in //photo image preload
            guard let self = self, let source = photo.source else { return }
            ImageProvider.shared.get(source)
                .catchError {
                    print($0.localizedDescription)
                    return .just(UIImage())
                }
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }

    // MARK: - * Main Logic --------------------
    private func bindViewModel() {
        
        let input = MainViewModel.Input(fetch: fetchNewFeedRelay.asObservable())
        let output = viewModel.transform(input: input)

        output.photos
            .do(onNext: { [weak self] photos in
                //generate workItems
                self?.workItems = photos.enumerated().reduce([String: DispatchWorkItem]()) {
                    var dict = $0
                    dict[$1.element.source ?? ""] = self?.generateWorkItem($1.element)
                    return dict
                }
            })
            .subscribe(onNext: { [unowned self] photos in
                self.workItems.forEach { self.dispatchQueue.sync(execute: $0.value) }   //workItems 실행
                self.prefetchedPhotos = photos //현재 목록을 모두 보여준 후 갱신할 포토 목록.
                
                self.restartNextSlideShow()
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                debugPrint(error)
                self?.showAlert(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func slideShow() {
        guard let photos = photos, photos.count > 0 else {
            self.showAlert("Slide show finished.\nBack to main?", completion: {
                self.navigationController?.popViewController(animated: true)
            })
            return
        }
        
        let photoObs = Observable.from(photos)
        let timer = Observable<Int>.timer(0, period: slideShowInterval + SlideShowViewController.imageTransitionTime, scheduler: MainScheduler.instance)
            .filter { [unowned self] _ in self.scrollView.zoomScale == self.scrollView.minimumZoomScale }

        timer2dis = timer.zip(with: photoObs) { $1 }
            .do(onNext: { [unowned self] in
                self.title = $0.title
                if self.photos.count == self.prefetchedPhotos.count || self.prefetchedPhotos.count == 0 {
                    self.fetchNewFeedRelay.accept(())
                }
                self.photos.removeFirst() //로드된 이미지를 제거해줌.
            }, onCompleted: { [unowned self] in
                self.restartNextSlideShow()
            })
            .flatMap { photo in
                ImageProvider.shared.get(photo.source ?? "")
                    .catchError {
                        print($0.localizedDescription)
                        return .just(UIImage())
                    }
            }
            .bind(onNext: { [unowned self] image in
                UIView.transition(with: self.imageView, duration: SlideShowViewController.imageTransitionTime, options: .transitionCrossDissolve, animations: {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                })
                
                if self.timeChanged == true {//재생 시간 변경 시, 다음 사진부터 적용.
                    self.timeChanged = false
                    self.timer2dis?.dispose()
                    self.slideShow()
                }
            })
    }
    
    private func restartNextSlideShow() {
        guard photos.count == 0 else { return }
        
        self.photos = self.prefetchedPhotos
        self.prefetchedPhotos.removeAll()
        
        self.slideShow() //현재 목록의 슬라이드쇼를 모두 출력한 경우, 다시 재게함.
    }

    // MARK: - * UI Events --------------------
    private func zoom(center: CGPoint) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            self.showToast("Resume slide show.")
        } else {
            scrollView.zoom(to: (zoomRectForScale(scale: scrollView.maximumZoomScale, center: center)), animated: true)
            self.showToast("Pause slide show when zoomed.")
        }
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}

//refer: https://github.com/aFrogleap/SimpleImageViewer
extension SlideShowViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image = imageView.image else { return }
        
        let imageViewSize = Utilities.aspectFitRect(forSize: image.size, insideRect: imageView.frame)
        let verticalInsets = -(scrollView.contentSize.height - max(imageViewSize.height, scrollView.bounds.height)) / 2
        let horizontalInsets = -(scrollView.contentSize.width - max(imageViewSize.width, scrollView.bounds.width)) / 2
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
    }
}

