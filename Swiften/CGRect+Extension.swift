//
//  CGRect+Extension.swift
//  Swiften
//
//  Created by Cator Vee on 5/24/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

extension CGRect {
    public var center: CGPoint {
        return CGPoint(x: CGRectGetMidX(self), y: CGRectGetMidY(self))
    }
}