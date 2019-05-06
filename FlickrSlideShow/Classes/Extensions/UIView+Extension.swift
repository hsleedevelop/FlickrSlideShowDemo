//
//  UIView+Extension.swift
//  FlickrSlideShow
//
//  Created by HS Lee on 02/05/2019.
//  Copyright © 2019 hsleedevelop.github.io All rights reserved.
//

import Foundation
import UIKit
    
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 3, height: 3)    //기본 설정 직접 입력받게 가능함.
            layer.shadowOpacity = 0.4
            layer.shadowRadius = shadowRadius
        }
    }
    
    /// 해당하는 constraint를 찾아 반환함.
    /// hslee
    /// - Parameter attribute: attribute
    /// - Returns: constraint
    func getConstraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        //first, find on super
        var constraint = superview?.constraints.first { $0.firstItem === self && $0.firstAttribute == attribute }
        constraint = constraint == nil ? superview?.constraints.first { $0.secondItem === self && $0.secondAttribute == attribute } : constraint
        
        //second, find on self
        constraint = constraint == nil ? self.constraints.reversed().first { $0.firstItem === self && $0.firstAttribute == attribute } : constraint
        return constraint
    }
}
