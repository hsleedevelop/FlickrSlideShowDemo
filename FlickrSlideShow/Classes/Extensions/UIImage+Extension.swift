//
//  UIImage+Extension.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 02/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    var memorySize: Int {
        guard let cgImage = self.cgImage else { return 0 }
        let cost = cgImage.height * cgImage.bytesPerRow
        //print("cost=\(cost)")
        return cost
    }
}
