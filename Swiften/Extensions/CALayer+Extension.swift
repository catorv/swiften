//
//  CALayer+Extension.swift
//  Swiften
//
//  Created by Cator Vee on 5/24/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

extension CALayer {
    public var borderUIColor: UIColor? {
        get {
            if let borderColor = borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
}
