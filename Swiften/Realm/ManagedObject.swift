//
// Created by Cator Vee on 2019-03-07.
// Copyright (c) 2019 haoyuan tan. All rights reserved.
//

import Foundation
import RealmSwift

public protocol ManagedObject where Self: Object {
    static var om: RealmObjectManager<Self> { get }
    
    var om: RealmObjectManager<Self> { get }

    // MARK: - Query Object

    static var all: Results<Self> { get }

    static func get(by key: Any) -> Self?

    // MARK: - Create Object

    static func create(_ value: Any) -> Self?

    // MARK: - Save Object

    func save()

    static func write(_ callback: () -> Void)
    
    func write(_ callback: () -> Void)

    // MARK: - Delete Object

    func delete()

    static func deleteAll()
}

public extension ManagedObject {

    var om: RealmObjectManager<Self> {
        return Self.om
    }
    
    static var all: Results<Self> {
        return om.objects
    }

    static func get(by key: Any) -> Self? {
        return om.object(primaryKey: key)
    }

    static func create(_ value: Any) -> Self? {
        return om.create(value)
    }

    func save() {
        Self.om.save(self)
    }

    static func write(_ callback: () -> Void) {
        om.write(callback)
    }
    
    func write(_ callback: () -> Void) {
        Self.om.write(callback)
    }

    func delete() {
        Self.om.delete(self)
    }

    static func deleteAll() {
        om.deleteAll()
    }
}

public extension List where Element: ManagedObject {
    func saveAll() {
        self.forEach { $0.save() }
    }
}

public extension Results where Element: ManagedObject {
    func saveAll() {
        self.forEach { $0.save() }
    }
}
