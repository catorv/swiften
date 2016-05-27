//
//  RealmCache.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class RealmCache: Cachable {

    public func value(forKey key: String) -> CacheItem? {
        return CacheItem.em.object(primaryKey: key)
    }

    public func setValue(value: CacheItem) {
        CacheItem.em.save(value)
    }

    public func string(forKey key: String) -> String? {
        return value(forKey: key)?.value
    }

    public func setString(value: String, forKey key: String, expires: Double?) {
        let item = CacheItem()
        item.key = key
        item.value = value
        item.expires = expires ?? NSDate.distantFuture().timeIntervalSince1970
        setValue(item)
    }

    public func remove(forKey key: String) {
        guard let item = value(forKey: key) else { return }
        CacheItem.em.delete(item)
    }

    public func clear() {
        CacheItem.em.deleteAll()
    }
}