//
//  Map+valueForKey.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import ObjectMapper

extension Map {
  func value<T>(forKey key: String) -> T? {
    var value: T?
    value <- self[key]
    return value
  }
}
