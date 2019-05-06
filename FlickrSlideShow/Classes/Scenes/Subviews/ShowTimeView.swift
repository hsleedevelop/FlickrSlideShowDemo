//
//  ShowTimeView.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 06/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ShowTimeView: UIView {
    // MARK: - * properties --------------------
    private var disposeBag = DisposeBag()
    private var selectedButton: UIButton!
    
    var isLoaded: BehaviorRelay<Bool> = .init(value: false)
    var slideShowInverval: TimeInterval = 1
    
    // MARK: - * Outlets --------------------
    @IBOutlet weak var infoLabel: UILabel! {
        didSet {
            infoLabel.text = "loading ."
            infoLabel.textColor = UIMetrics.color.systemGray
        }
    }
    @IBOutlet var upButtons: [UIButton]!
    @IBOutlet var dnButtons: [UIButton]!
    
    // MARK: - * overrides --------------------
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedButton = upButtons.first
        isLoaded.asDriver()
            .drive(onNext: { [unowned self] isLoaded in
                self.infoLabel.text = isLoaded ? "Ready to play each slide for: 1sec" : "loading ."
                self.infoLabel.textColor = isLoaded ? UIMetrics.color.point : UIMetrics.color.systemGray
                self.selectedButton.isSelected = isLoaded
                if isLoaded {
                    self.upButtons.first?.sendActions(for: .touchUpInside)
                }
            })
            .disposed(by: disposeBag)
        
        Driver.merge((upButtons + dnButtons).map { btn in btn.rx.tap.asDriver().map { btn } })
            .filter { [unowned self] in self.isLoaded.value && self.selectedButton !== $0 }
            .drive(onNext: { [unowned self] in
                $0.isSelected = true
                self.selectedButton.isSelected = !$0.isSelected
                self.selectedButton = $0
                
                let title = $0.title(for: .normal) ?? ""
                self.infoLabel.text = "Ready to play each slide for: \(title)"
                self.slideShowInverval = TimeInterval(title.matchingStrings(regex: "[0-9]*").first?.first ?? "1") ?? 0
            })
            .disposed(by: disposeBag)
    }
    
//    func reset() {
//        upButtons.first?.sendActions(for: .touchUpInside)
//        isLoaded.accept(false)
//    }
}
