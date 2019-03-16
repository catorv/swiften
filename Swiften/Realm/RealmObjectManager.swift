//
//  RealmObjectManager.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import RealmSwift

open class RealmObjectManager<T: Object> {
    
    open var realm: Realm
    
    public init(realm: Realm) {
        self.realm = realm
    }
    
    public convenience init() {
        self.init(realm: Realm.shared)
    }
    
    // MARK: - Query Object
    
    open var objects: Results<T> {
        return realm.objects(T.self)
    }
    
    open func object(primaryKey key: Any) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }
    
    // MARK: - Create Object
    
    open func create(_ value: Any) -> T? {
        var object: T?
        do {
            try realm.write { [weak realm] in
                object = realm?.create(T.self, value: value, update: true)
            }
        } catch let error {
            Log.error("ObjectManager: \(error)")
        }
        return object
    }
    
    // MARK: - Save Object
    
    open func save(_ object: T) {
        do {
            try realm.write { [weak realm] in
                if object.objectSchema.primaryKeyProperty == nil {
                    realm?.add(object)
                } else {
                    realm?.add(object, update: true)
                }
            }
        } catch let error {
            Log.error("ObjectManager: \(error)")
        }
    }
    
    open func write(_ callback: () -> Void) {
        do {
            try realm.write(callback)
        } catch let error {
            Log.error("ObjectManager: \(error)")
        }
    }
    
    // MARK: - Delete Object
    
    open func delete(_ object: T) {
        do {
            try realm.write { [weak realm] in
                realm?.delete(object)
            }
        } catch let error {
            Log.error("ObjectManager: \(error)")
        }
    }
    
    open func delete<S: Sequence>(_ objects: S) where S.Iterator.Element: Object {
        do {
            try realm.write { [weak realm] in
                realm?.delete(objects)
            }
        } catch let error {
            Log.error("ObjectManager: \(error)")
        }
    }
    
    open func delete(primaryKey key: Any) {
        if let object = object(primaryKey: key) {
            delete(object)
        }
    }
    
    open func deleteAll() {
        do {
            try realm.write { [objects, weak realm] in
                realm?.delete(objects)
            }
        } catch let error as NSError {
            Log.error("ObjectManager: \(error)")
        }
    }
    
}

extension Results where Element: Object {
    func deleteAll() {
        guard !isEmpty else {
            return
        }
        if let realm = self.realm {
            do {
                try realm.write { [weak realm] in
                    realm?.delete(self)
                }
            } catch let error {
                Log.error("ObjectManager: \(error)")
            }
        }
    }
}

extension List where Element: Object {
    func deleteAll() {
        guard !isEmpty else {
            return
        }
        if let realm = self.realm {
            do {
                try realm.write { [weak realm] in
                    realm?.delete(self)
                }
            } catch let error {
                Log.error("ObjectManager: \(error)")
            }
        }
    }
}
