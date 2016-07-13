//
// Created by Cator Vee on 7/10/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

public class RestResponse<T:Mappable>: Mappable {
    
    /// HTTP响应的Headers
    public var headers: [NSObject : AnyObject]?
    /// HTTP响应返回去的内容
    public var rawData: NSData?
    /// `rawData`属性的String对象
    public var rawString: String? {
        return rawData == nil ? nil : String(data: rawData!, encoding: NSUTF8StringEncoding)
    }
    /// HTTP响应内容的JSON对象
    public var json: JSON? {
        return rawData == nil ? nil : JSON(data: rawData!)
    }

    /// 错误信息
    public var error: RestError?

    /// ObjectMapper原始Map对象
    public var map: Map!
    
    public var code = -1
    public var msg: T?
    public var errorMessage: String?
    
    var isOK: Bool {
        return code == 0 && msg != nil && error == nil
    }

    public init() {
        // nothing
    }
    
    public init(error: RestError) {
        self.error = error
    }

    public required init?(_ map: Map) {
        self.map = map
    }

    public func mapping(map: Map) {
        code <- map[Rest.responseCodeField]
        errorMessage <- map[Rest.responseErrorMessageField]
        if code == 0 {
            msg <- map[Rest.responseMessageField]
//            let value = map.currentValue
//            if value is String || value is Bool || value is Int || value is Array<AnyObject> {
//                msg = T(map)
//            }
        } else {
            error = .resultError(code: code, message: errorMessage ?? "")
            Log.error("rest: ResultError[\(code)] \(errorMessage ?? "")")
        }
    }
}

public class RestBaseModel: Mappable {
    
    private var map: Map!
    private var currentValue: AnyObject?
    
    public var string: String? { return value() }
    public var stringValue: String { return string ?? "" }
    
    public var bool: Bool? { return value() }
    public var boolValue: Bool { return bool ?? false }
    
    public var int: Int? { return value() }
    public var intValue: Int { return int ?? 0 }
    
    public var double: Double? { return value() }
    public var doubleValue: Double { return double ?? 0.0 }
    
    public required init?(_ map: Map) {
        self.map = map
        self.currentValue = map.currentValue
    }
    
    public func mapping(map: Map) {
        
    }
    
    public func value<T>() -> T? {
        if let value = currentValue as? T {
            return value
        }
        return nil
    }
    
    public subscript(key: String) -> AnyObject? {
        guard map != nil && map.isValid else {
            return nil
        }
        var result: AnyObject?
        result <- map[key]
        return result
    }
}