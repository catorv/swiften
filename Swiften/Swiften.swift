//
//  Swiften.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

fileprivate var needsInitFramework = true
public func initFramework() {
    guard needsInitFramework else {
        return
    }
    needsInitFramework = false
    
    UIView.swizzle()
}
