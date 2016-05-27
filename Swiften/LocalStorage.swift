//
//  LocalStorage.swift
//  Swiften
//
//  Created by Cator Vee on 5/24/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public class LocalStorage {
    private var defaults = NSUserDefaults.standardUserDefaults()
    private var autoCommit = true

    public func setObject(object: AnyObject?, forKey key: String) {
        if object == nil {
            defaults.removeObjectForKey(key)
            return
        }
        
        defaults.setObject(object!, forKey: key)
        if autoCommit {
            defaults.synchronize()
        }
    }
    
    public func object(forKey key: String) -> AnyObject? {
        return defaults.objectForKey(key)
    }
    
    public func integer(forKey key: String) -> Int {
        return defaults.integerForKey(key)
    }
    
    public func float(forKey key: String) -> Float {
        return defaults.floatForKey(key)
    }
    
    public func double(forKey key: String) -> Double {
        return defaults.doubleForKey(key)
    }
    
    public func string(forKey key: String) -> String? {
        return defaults.stringForKey(key)
    }
    
    public func string(forKey key: String, defaultValue: String) -> String {
        if let result = defaults.stringForKey(key) {
            return result
        } else {
            return defaultValue
        }
    }
    
    public func array(forKey key: String) -> [AnyObject]? {
        return defaults.arrayForKey(key)
    }
    
    public func dictionary(forKey key: String) -> [String: AnyObject]? {
        return defaults.dictionaryForKey(key)
    }
    
    public func date(forKey key: String) -> NSDate! {
        var result = defaults.objectForKey(key) as? NSDate
        
        if result == nil {
            result = NSDate.distantPast()
        }
        
        return result!
    }
    
    public func reset() {
        NSUserDefaults.resetStandardUserDefaults()
    }
    
    public func begin() {
        autoCommit = false
    }
    
    public func commit() {
        defaults.synchronize()
        autoCommit = true
    }
}