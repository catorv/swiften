//
//  Cache.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: - CacheValue

public protocol CacheValue {
    var key: String { get set }
    var value: String { get set }
    var expires: TimeInterval { get set }
    var isValid: Bool { get }
}

// MARK: - Cachable

public protocol Cachable {
    
    associatedtype Value: CacheValue
    
    func value(for key: String) -> Value?
    func set(value: Value)
    
    func string(for key: String) -> String?
    func set(string value: String, for key: String, expires: TimeInterval)
    
    func remove(for key: String)
    func removeAll()
}

// MARK: - CacheManager

open class CacheManager<C: Cachable> {
    
    public let cachable: C
    
    public init(_ cachable: C) {
        self.cachable = cachable
    }
    
    // MARK: - Methods
    
    public func object<T: Mappable>(for key: String) -> T? {
        guard let jsonString = cachable.string(for: key) else {
            return nil
        }
        return Mapper<T>().map(JSONString: jsonString)
    }
    
    public func set<T: Mappable>(object: T, for key: String, expires: Double = 0.0) {
        guard let jsonString = Mapper<T>().toJSONString(object) else {
            return
        }
        cachable.set(string: jsonString, for: key, expires: expires)
    }
    
    public func remove(for key: String) {
        cachable.remove(for: key)
    }
    
    public func removeAll() {
        cachable.removeAll()
    }
    
    // MARK: - Subscript
    
    public subscript(key: String) -> String? {
        get {
            return cachable.string(for: key)
        }
        set {
            if let string = newValue {
                cachable.set(string: string, for: key, expires: 0.0)
            } else {
                cachable.remove(for: key)
            }
        }
    }
    
    public subscript(key: String) -> Int? {
        get {
            return cachable.string(for: key)?.intValue
        }
        set {
            if let value = newValue {
                cachable.set(string: String(value), for: key, expires: 0.0)
            } else {
                cachable.remove(for: key)
            }
        }
    }
    
    public subscript(key: String) -> Double? {
        get {
            return cachable.string(for: key)?.doubleValue
        }
        set {
            if let value = newValue {
                cachable.set(string: String(value), for: key, expires: 0.0)
            } else {
                cachable.remove(for: key)
            }
        }
    }
    
    public subscript(key: String) -> Bool? {
        get {
            return cachable.string(for: key)?.boolValue
        }
        set {
            if let value = newValue {
                cachable.set(string: String(value), for: key, expires: 0.0)
            } else {
                cachable.remove(for: key)
            }
        }
    }
    
}

