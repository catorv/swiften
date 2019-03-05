//
//  RealmCache.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import RealmSwift

open class RealmCacheValue: Object, CacheValue {
    @objc dynamic public var key: String = ""
    @objc dynamic public var value: String = ""
    @objc dynamic public var expires: TimeInterval = 0.0
    
    public static let om = RealmObjectManager<RealmCacheValue>(realm: Realm.createRealm(name: "cache")!)
    
    // 主键
    override open class func primaryKey() -> String? {
        return "key"
    }
    
    public var isValid: Bool {
        return expires < 0.000001 || expires > Date.timeIntervalSinceReferenceDate
    }
}

open class RealmCache: Cachable {
    
    public typealias Value = RealmCacheValue
    
    public init() {
        
    }
    
    public func value(for key: String) -> RealmCacheValue? {
        guard let cacheValue = RealmCacheValue.om.object(primaryKey: key as AnyObject), cacheValue.isValid else {
            return nil
        }
        return cacheValue
    }
    
    public func set(value: RealmCacheValue) {
        RealmCacheValue.om.save(value)
    }
    
    public func string(for key: String) -> String? {
        return value(for: key)?.value
    }
    
    public func set(string value: String, for key: String, expires: TimeInterval) {
        if !key.isEmpty {
            let cacheValue = RealmCacheValue()
            cacheValue.key = key
            cacheValue.value = value
            cacheValue.expires = expires
            set(value: cacheValue)
        }
    }
    
    public func remove(for key: String) {
        guard let item = value(for: key) else {
            return
        }
        RealmCacheValue.om.delete(item)
    }
    
    public func removeAll() {
        RealmCacheValue.om.deleteAll()
    }
    
}
