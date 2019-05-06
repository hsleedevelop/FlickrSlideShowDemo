//
//  ImageProvider.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

///이미지 다운로드 제공
final class ImageProvider {
    static let memorySize = 50 * 1024 * 1024 //50 mega
    static let countLimit = 200
    
    //MARK: * Singleton --------------------
    static let shared = ImageProvider()
    
    ///cache
    private let imageCache: LRUCache<String, UIImage>

    private let defaultTotalCostLimit: Int = {
        let physicalMemory = ProcessInfo().physicalMemory
        let ratio = physicalMemory <= (ImageProvider.memorySize * 1024 * 1024) ? 0.1 : 0.2
        let limit = physicalMemory / UInt64(1 / ratio)
        return min(Int.max, Int(limit))
    }()
    
    private init() {
        imageCache = LRUCache()
        imageCache.totalCostLimit = defaultTotalCostLimit < ImageProvider.memorySize ? defaultTotalCostLimit : ImageProvider.memorySize
        imageCache.countLimit = ImageProvider.countLimit
    }
    
    // MARK: - * Main Business --------------------
    func get(_ urlString: String) -> Observable<UIImage> {
        
        guard let url = URL(string: urlString) else {
            return Observable.error(NetworkError.error("잘못된 URL입니다."))
        }
        
        return Observable.create { observer in
            var task: URLSessionDataTask?
            
            let cachedImage = self.imageCache.value(for: urlString)
            if let image = cachedImage {//캐시에서 읽는 경우,
                observer.onNext(image)
                observer.onCompleted()
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true   //trackActivity 대신 사용.
                }
                task = URLSession.shared.dataTask(with: url) { data, response, error in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    do {
                        if let data = data, let image = UIImage(data: data) {
                            self.imageCache.set(image, for: urlString, cost: image.memorySize, identifier: url.pathComponents.last ?? "") //캐시에 저장
                            observer.onNext(image)
                        } else {
                            throw NetworkError.error("no image data")
                        }
                    } catch let error {
                        observer.onError(error)
                    }
                    observer.onCompleted()
                }
            }
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
