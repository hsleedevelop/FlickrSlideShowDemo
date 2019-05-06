//
//  FlowCoordinator.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 30/04/2019.
//  Copyright © 2019 hsleedevelop.github.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

///플로우 제어
final class FlowCoordinator: ReactiveCompatible {
    static let shared = FlowCoordinator()
    
    enum Step: ReactiveCompatible {
        case main
        case slideShow([Photo], TimeInterval)
        
        var identifier: String {
            switch self {
            case .main:
                return "MainViewController"
            case .slideShow:
                return "SlideShowViewController"
            }
        }
        
        /// 뷰컨트롤러 로딩
        ///
        /// - Parameters:
        ///   - parentVc: 로딩하고자 하는 부모 뷰컨트롤러
        ///   - window: 로딩하고자 하는 윈도우
        func load(parentViewController parentVc: UIViewController? = nil, window: UIWindow? = nil) {
            switch self {
            case .main:
                guard let mainVC = (viewController() ?? UIViewController()) as? MainViewController else {
                    return
                }
                let nvc = UINavigationController(rootViewController: mainVC)
                
                window?.rootViewController = nvc
                window?.makeKeyAndVisible()
                
            case let .slideShow(photos, interval):
                guard let slideShowVC = (viewController() ?? UIViewController()) as? SlideShowViewController else {
                    return
                }
                slideShowVC.photos = photos
                slideShowVC.slideShowInterval = interval
                
                parentVc?.navigationController?.pushViewController(slideShowVC, animated: true)
                parentVc?.navigationController?.setNavigationBarHidden(false, animated: true)
                
            }
        }
        
        ///뷰 컨트롤러 generate
        private func viewController() -> UIViewController? {
            return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: self.identifier)
        }
    }
}

extension Reactive where Base: FlowCoordinator {
    
    ///페이지 흐름 제어 바인더
    var flow: Binder<(FlowCoordinator.Step, UIViewController?, UIWindow?)> {
        return Binder(self.base) { _, value in
            value.0.load(parentViewController: value.1, window: value.2)
        }
    }
}
