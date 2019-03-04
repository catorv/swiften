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
    
    public static let defaultRootUrl = Realm.Configuration.defaultConfiguration.fileURL?.deletingLastPathComponent()
    
    public static var shared: Realm! = createRealm(name: "shared")
    
    public static var system: Realm! = createRealm(name: "system")
    
    public static func createRealm(name: String) -> Realm? {
        guard let url = defaultRootUrl?.appendingPathComponent("\(name).realm") else {
            Log.error("无效的数据库路径： \(name).realm in \(String(describing: defaultRootUrl))")
            return nil
        }
        do {
            if let root = defaultRootUrl?.absoluteString {
                if !FileManager.default.fileExists(atPath: root) {
                    try FileManager.default.createDirectory(atPath: root, withIntermediateDirectories: true, attributes: nil)
                }
            }
            Log.debug("读取数据库: \(url.absoluteString)")
            return try Realm(fileURL: url)
        } catch let error {
            Log.error("创建数据库失败：\(error)")
        }
        return nil
    }
    
}
