//
//  Photo.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import FeedKit

struct Photo: Equatable {
    let pid: String?
    let title: String?
    let source: String?
    
    init?(entry: AtomFeedEntry) {
        guard let link = entry.links?.first(where: { $0.attributes?.rel == "enclosure" })?.attributes?.href else {
            return nil
        }
        self.source = link
        self.title = entry.title
        self.pid = entry.id
    }
}

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.pid == rhs.pid
}
