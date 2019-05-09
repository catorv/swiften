//
//  Realm+Manager.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
//    fileprivate struct AssociatedKey {
//        static var queue: Int = 0
//    }
//
//    public var queue: DispatchQueue {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKey.queue) as? DispatchQueue ?? DispatchQueue.global()
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKey.queue, newValue, .OBJC_ASSOCIATION_RETAIN)
//        }
//    }
    
    public static let defaultRootUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first //Realm.Configuration.defaultConfiguration.fileURL?.deletingLastPathComponent()
    
    public static var shared: Realm! = createRealm(name: "shared")
    
    public static var system: Realm! = createRealm(name: "system")
    
    public static func createRealm(name: String) -> Realm? {
        guard let root = defaultRootUrl else {
            Log.error("无效的数据库路径： \(name).realm in \(String(describing: defaultRootUrl))")
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: root.path) {
            do {
             try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                Log.error("创建数据库目录失败：\(error)")
            }
        }
        let url = root.appendingPathComponent("\(name).realm")
        do {
            Log.debug("数据库路径: \(url.absoluteString)")
            let realm = try Realm(fileURL: url)
//            realm.queue = DispatchQueue(label: name)
            return realm
        } catch let error {
            Log.error("创建数据库失败：\(error)")
        }
        return nil
    }
    
    public func muteWrite(_ block: (() throws -> Void)) {
        do {
            if isInWriteTransaction {
                try block()
            } else {
                try write(block)
            }
        } catch let error as NSError {
            Log.error("ObjectManager: \(error)")
        }
//        queue.sync {
//            do {
//                try self.write(block)
//            } catch let error as NSError {
//                Log.error("ObjectManager: \(error)")
//            }
//        }
    }
    
}
