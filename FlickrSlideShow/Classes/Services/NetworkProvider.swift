//
//  NetworkProvider.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation

///API 프로바이더 관리 목적
final class NetworkProvider {
    static let shared = NetworkProvider()
    
    let flickr = FlickrProvider()
}
