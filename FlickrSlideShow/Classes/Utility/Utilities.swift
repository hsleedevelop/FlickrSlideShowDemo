//
//  Utilities.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 06/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct Utilities {
    static func rect(forSize size: CGSize) -> CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    static func aspectFitRect(forSize size: CGSize, insideRect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: size, insideRect: insideRect)
    }
}
