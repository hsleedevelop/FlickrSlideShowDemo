//
//  String+Extension.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 02/05/2019.
//  Copyright © 2019 hsleedevelop.github.io All rights reserved.
//

import Foundation
import UIKit

extension String {
    ///-> https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    func matchingStrings(regex: String) -> [[String]] {//by grouping
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results = regex.matches(in: self, options: [], range: .init(location: 0, length: nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound ? nsString.substring(with: result.range(at: $0)) : ""
            }
        }
    }
}
