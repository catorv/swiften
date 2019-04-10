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
            return try Realm(fileURL: url)
        } catch let error {
            Log.error("创建数据库失败：\(error)")
        }
        return nil
    }
    
}
