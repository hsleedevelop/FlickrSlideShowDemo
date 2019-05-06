//
//  CommonError.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 30/04/2019.
//  Copyright © 2019 hsleedevelop.github.io All rights reserved.
//

import Foundation

///로컬 에러
enum LocalError: Error {
    case error(String)
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        }
    }
    
    ///특정 에러의 경우, 액션을 취할 수도 있음
    func action() {
        
    }
}

///API 또는 네트워크 에러
enum NetworkError: Error {
    case error(String)
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        }
    }
    
    ///특정 에러의 경우, 액션을 취할 수도 있음
    func action() {
        
    }
}

