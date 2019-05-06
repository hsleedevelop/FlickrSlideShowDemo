//
//  FlickrAPI.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation

protocol API {
    var url: String { get }
}

enum FlickrAPI: API {
    case photosPublic
    
    private var path: String {
        switch self {
        case .photosPublic:
            return "/services/feeds/photos_public.gne?tags=landscape,portrait&tagmode=any"
        }
    }
    
    var url: String {
        switch self {
        case .photosPublic:
            return Environment.domain + self.path
        }
    }
}
