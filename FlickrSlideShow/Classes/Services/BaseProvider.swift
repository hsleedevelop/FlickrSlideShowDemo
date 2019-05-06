//
//  BaseProvider.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

///API 제공 프로토콜
protocol APIProvider {
    
}

///API Base 프로바이더
class BaseProvider<T: API> {
    
}

extension BaseProvider {
    
    /// API request
    /// moya concept을 빌려옴
    /// - Parameter api: api path generic
    /// - Returns: response date
    func request(api: T) -> Observable<Data> {
        
        guard let encodedUrlString = api.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedUrlString) else {
            return Observable.error(NetworkError.error("잘못된 URL입니다."))
        }
        
        #if DEBUG
        print("url=\(url)")
        #endif
        
        //또는 -> URLSession.shared.rx.json(request: request)
        return Observable.create { observer in
            
            let request = NSMutableURLRequest(url: url)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ... 399 ~= statusCode {//서버의 응답 결과 정의 후 다양하게 처리 가능..
                        observer.onNext(data ?? Data())
                    } else {
                        observer.onError(NetworkError.error(HTTPURLResponse.localizedString(forStatusCode: statusCode)))
                    }
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

///// extesion concept from Moya RxSwift
/////Moya 구현 대신 비교적 간단한 스펙이라서 직접 구현함.
//extension Data {
//    func map<T: Decodable>(_ type: T.Type) throws -> T {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        do {
//            return try decoder.decode(T.self, from: self)
//        } catch let error {
//            throw error
//        }
//    }
//}
