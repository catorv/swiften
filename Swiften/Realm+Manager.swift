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
    
    private static let rootPath = (Realm.Configuration.defaultConfiguration.path! as NSString).stringByDeletingLastPathComponent
    
    static private var _userRealm: Realm!
    static func userRealm() -> Realm {
        if _userRealm == nil {
            //let realm = Realm.sharedRealm()
            //if let user = auth.user {
                //Realm._userRealm = try! Realm(path: "\(Realm.rootPath)/\(user.id).realm")
            //} else {
                //return realm
            //}
        }
        return _userRealm
    }
    
    public static func setUserRealm(realm: Realm) {
        _userRealm = realm
    }
    
    public static func resetUserRealm() {
        _userRealm = nil
    }
    
    private static var _sharedRealm: Realm!
    public static var sharedRealm: Realm {
        if _sharedRealm == nil {
            _sharedRealm = try! Realm(path: "\(rootPath)/shared.realm")
        }
        return _sharedRealm
    }
    
    public static func setSharedRealm(realm: Realm) {
        _sharedRealm = realm
    }
}