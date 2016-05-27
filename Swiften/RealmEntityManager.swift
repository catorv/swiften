//
//  RealmEntityManager.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmEntityManager<T: Object> {

    public var realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }
    
    // MARK: - Query Entity

    public var objects: Results<T> {
        return realm.objects(T)
    }

    public func object(primaryKey key: AnyObject) -> T? {
        return realm.objectForPrimaryKey(T.self, key: key)
    }

    public func query(predicateFormat: String, _ args: AnyObject...) -> Results<T> {
        return objects.filter(predicateFormat, args)
    }

    public func query(predicate: NSPredicate) -> Results<T> {
        return objects.filter(predicate)
    }

    // MARK: - Create Entity

    public func create(value: AnyObject) -> T? {
        var entity: T?
        do {
            try realm.write { [weak realm] in
                entity = realm?.create(T.self, value: value, update: true)
            }
        } catch let error {
            Log.error("EntityManager: \(error)")
        }
        return entity
    }

    // MARK: - Save Entity

    public func save(object: T) {
        do {
            try realm.write { [weak realm] in
                realm?.add(object, update: true)
            }
        } catch let error {
            Log.error("EntityManager: \(error)")
        }
    }

    // MARK: - Delete Entity

    public func delete(object: T) {
        do {
            try realm.write { [weak realm] in
                realm?.delete(object)
            }
        } catch let error {
            Log.error("EntityManager: \(error)")
        }
    }

    public func delete(objects: Results<T>) {
        do {
            try realm.write { [weak realm] in
                realm?.delete(objects)
            }
        } catch let error {
            Log.error("EntityManager: \(error)")
        }
    }

    public func delete(objects: List<T>) {
        do {
            try realm.write { [weak realm] in
                realm?.delete(objects)
            }
        } catch let error {
            Log.error("EntityManager: \(error)")
        }
    }

    public func delete<S: SequenceType where S.Generator.Element: Object>(objects: S) {
        do {
            try realm.write { [weak realm] in
                realm?.delete(objects)
            }
        } catch let error {
            Log.error("EntityManager: \(error)")
        }
    }

    public func delete(predicateFormat: String, _ args: AnyObject...) {
        delete(objects.filter(predicateFormat, args))
    }

    public func delete(predicate: NSPredicate) {
        delete(objects.filter(predicate))
    }

    public func delete(primaryKey key: AnyObject) {
        if let object = object(primaryKey: key) {
            delete(object)
        }
    }

    public func deleteAll() {
        do {
            try realm.write { [objects, weak realm] in
                realm?.delete(objects)
            }
        } catch let error as NSError {
            Log.error("EntityManager: \(error)")
        }
    }

}