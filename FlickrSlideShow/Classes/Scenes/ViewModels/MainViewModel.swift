//
//  MainViewModel.swift
//  FlickrSlideShow
//
//  Created by Gerard on 30/04/2019.
//  Copyright © 2019 hsleedevelop.github.io All rights reserved.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxSwiftUtilities

///메인화면 ViewModel
final class MainViewModel {
    ///데이터 흐름 처리
    func transform(input: Input) -> Output {
        
        let activity = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let fetchedPhotos = input.fetch
            .flatMap {
                NetworkProvider.shared.flickr.publicPhotos()
                    .trackActivity(activity)
                    .trackError(errorTracker)
                    .catchErrorJustReturn([])
            }
        
        return Output(photos: fetchedPhotos.share(),
                      isLoading: activity.asDriver(),
                      error: errorTracker.asDriver())
    }
}

extension MainViewModel {
    struct Input {
        let fetch: Observable<Void>
    }
    
    struct Output {
        var photos: Observable<([Photo])>
        var isLoading: Driver<Bool>
        var error: Driver<Error>
    }
}
