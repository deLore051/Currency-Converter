//
//  UIView+Additions.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 28.10.21..
//

import UIKit

extension UIView {
    var width: CGFloat {
        frame.size.width
    }
    var height: CGFloat {
        frame.size.height
    }
    var left: CGFloat {
        frame.origin.x
    }
    var right: CGFloat {
        left + width
    }
    var top: CGFloat {
        frame.origin.y
    }
    var bottom: CGFloat {
        top + height
    }
}
