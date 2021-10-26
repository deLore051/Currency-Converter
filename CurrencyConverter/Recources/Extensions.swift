//
//  Extensions.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 25.10.21..
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

extension UIButton {
    
    public func tapEffect(sender: UIButton) {
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            sender.alpha = 1
        }
    }
}

extension Date {
    
    public func onlyDate(from date: String) -> Date {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "en_US")
        dateFormater.dateFormat = "MM-dd-yyyy'T'HH:mm:ss"
        let date = dateFormater.date(from: date) ?? Date()
        return date
    }
    
   
}
