//
//  ViewModelType.swift
//  FlickrSlideShow
//
//  reference : https://en.wikipedia.org/wiki/Black_box
//  https://medium.com/@SergDort/viewmodel-in-rxswift-world-13d39faa2cf5
//  https://github.com/sergdort/CleanArchitectureRxSwift
//
//  Created by HS Lee on 30/04/2019.
//  Copyright © 2019 hsleedevelop.github.io All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
