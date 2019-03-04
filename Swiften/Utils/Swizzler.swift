//
//  Swizzler.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public struct Swizzler {
    public static func swizzleMethod(_ selector: Selector, with swizzledSelector: Selector, forClass: AnyClass!) {
        let originalMethod = class_getInstanceMethod(forClass, selector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
