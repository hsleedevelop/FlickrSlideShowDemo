//
//  FlickrProvider.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import FeedKit

final class FlickrProvider: BaseProvider<FlickrAPI> {

    //MARK: * Main Logic --------------------
    func publicPhotos() -> Observable<[Photo]> {
        return request(api: .photosPublic)
            .map { data -> AtomFeed in
                let parser = FeedParser(data: data)
                let result = parser.parse()
                switch result {
                case let .atom(feed):
                    return feed
                case let .failure(error):
                    #if DEBUG
                    debugPrint(error)
                    #endif
                    throw LocalError.error("parse error")
                default:
                    throw LocalError.error("no atom feed")
                }
            }
            .map { feed in
                feed.entries?.compactMap { Photo(entry: $0) } ?? []
            }
    }
}
