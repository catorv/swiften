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
        realm.writeSync { [weak realm] in
            object = realm?.create(T.self, value: value, update: true)
        }
        return object
    }
    
    // MARK: - Save Object
    
    open func save(_ object: T) {
        realm.writeSync { [weak realm] in
            if object.objectSchema.primaryKeyProperty == nil {
                realm?.add(object)
            } else {
                realm?.add(object, update: true)
            }
        }
    }
    
    open func write(_ callback: () -> Void) {
        realm.writeSync(callback)
    }
    
    // MARK: - Delete Object
    
    open func delete(_ object: T) {
        realm.writeSync { [weak realm] in
            realm?.delete(object)
        }
    }
    
    open func delete<S: Sequence>(_ objects: S) where S.Iterator.Element: Object {
        realm.writeSync { [weak realm] in
            realm?.delete(objects)
        }
    }
    
    open func delete(primaryKey key: Any) {
        if let object = object(primaryKey: key) {
            delete(object)
        }
    }
    
    open func deleteAll() {
        realm.writeSync { [objects, weak realm] in
            realm?.delete(objects)
        }
    }
}

public extension Results where Element: Object {
    func deleteAll() {
        guard !isEmpty, let realm = realm else { return }
        realm.writeSync { realm.delete(self) }
    }
}

public extension List where Element: Object {
    func deleteAll() {
        guard !isEmpty, let realm = realm else { return }
        realm.writeSync { realm.delete(self) }
    }
}
