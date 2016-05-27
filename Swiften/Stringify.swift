//
//  Stringify.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - JSON

extension String {
    /// String to JSON
    public var json: JSON { return JSON(data: self.data) }
}

extension JSON {
    /// JSON to String
    public var jsonString: String { return rawString(NSUTF8StringEncoding, options: NSJSONWritingOptions()) ?? "" }
}

// MARK: - NSData

extension String {
    /// 返回UTF8字符集的NSData对象
    public var data: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
}

extension NSData {
    /// 返回UTF8字符串
    public var string: String {
        return String(data: self, encoding: NSUTF8StringEncoding) ?? ""
    }
}

// MARK: - Int

extension String {
    public var int: Int32 { return (self as NSString).intValue }
    public var integer: Int { return (self as NSString).integerValue }
}

extension Int {
    public var string: String { return String(self) }
}

// MARK: - Float

extension String {
    public var float: Float { return (self as NSString).floatValue }
}

extension Float {
    public var string: String { return String(self) }
}

// MARK: - Double

extension String {
    public var double: Double { return (self as NSString).doubleValue }
}

extension Double {
    public var string: String { return String(self) }
}

// MARK: - Bool

extension String {
    public var bool: Bool { return (self as NSString).boolValue }
}

extension Bool {
    public var string: String { return self ? "true" : "false" }
}