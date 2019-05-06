//
//  MainViewController.swift
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
import Toast_Swift
    
final class MainViewController: UIViewController {

    // MARK: - * properties --------------------
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var reachability: Reachability? = Reachability()
    
    private var dispatchQueue = DispatchQueue(label: "io.hsleedevelop.photo.queue", qos: DispatchQoS.background, attributes: .concurrent)
    private var workItems = [String: DispatchWorkItem]()
    
    private var viewWillAppearRelay: PublishRelay<Void> = .init()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.isHidden = true
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
        }
    }
    @IBOutlet weak var showTimeView: ShowTimeView!
    
    // MARK: - * LifeCycle --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
     
        initUI()
        setupRx()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearRelay.accept(())
        try? reachability?.startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability?.stopNotifier()
    }

    // MARK: - * init & setup --------------------
    private func initUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupRx() {
        reachability?.rx.isReachable
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] isReachable in
                var message = ""
                if !isReachable {
                    message = "Network is disconnected."
                    print(">>> Network is disconnected.")
                    self.showTimeView.isLoaded.accept(false)
                } else {
                    self.viewWillAppearRelay.accept(())
                    message = "Network is connected."
                    print(">>> Network is connected.")
                }
                self.showToast(message)
            })
            .disposed(by: disposeBag)
        
        self.showTimeView.isLoaded.asObservable()
            .map { !$0 }
            .bind(to: self.playButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - * Main Logic --------------------
    ///이미지 프리패치
    private func generateWorkItem(_ photo: Photo) -> DispatchWorkItem {
        return DispatchWorkItem { [weak self] in //photo image preload
            guard let self = self, let source = photo.source else { return }
            ImageProvider.shared.get(source)
                .catchError {
                    print($0.localizedDescription)
                    return .just(UIImage())
                }
                .filter { _ in !self.showTimeView.isLoaded.value }  //이미지 1개 로딩 시,,
                .map { _ in true }
                .bind(to: self.showTimeView.isLoaded)
                .disposed(by: self.disposeBag)
        }
    }
    
    private func bindViewModel() {
        
        let viewWillAppearObs = viewWillAppearRelay.asObservable()
            .do(onNext: { [unowned self] _ in
                self.playButton.isHidden = true
                self.showTimeView.isLoaded.accept(false)
            })
        
        let input = MainViewModel.Input(fetch: viewWillAppearObs)
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
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)

        if let reachability = reachability {//리퀘스트와 네트워크 연결상태를 combine
            Driver.combineLatest(output.isLoading, reachability.rx.isReachable.asDriver(onErrorJustReturn: false))
                .map { $0 || !$1 }
                .drive(activityIndicator.rx.isAnimating)
                .disposed(by: disposeBag)
        }

        output.error
            .drive(onNext: { [weak self] error in
                debugPrint(error)
                self?.showAlert(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        playButton.rx.tap.asObservable().withLatestFrom(output.photos)
            .asDriverOnErrorJustComplete()
            .map { [unowned self] in (FlowCoordinator.Step.slideShow($0, self.showTimeView?.slideShowInverval ?? 0), self, nil) }
            .drive(FlowCoordinator.shared.rx.flow)
            .disposed(by: disposeBag)
    }
}

extension UIViewController {
    ///얼럿 출력
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        var cancelTitle = "OK"
        if let completion = completion {
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completion()
            }
            alert.addAction(okAction)
            cancelTitle = "cancel"
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    ///토스트 출력
    func showToast(_ message: String, duration: TimeInterval = 2.0) {
        self.view.makeToast(message, duration: duration)
    }
}
