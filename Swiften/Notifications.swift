//
//  Notifications.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public struct Notifications {

    public static let notificationCenter = NSNotificationCenter.defaultCenter()
    
    public static let reachabilityChanged = Proxy(name: "ReachabilityChanged")

    public class Proxy {
        private let name: String

        init(name: String) {
            self.name = name
        }

        public func post(object: AnyObject? = nil, userInfo: [String: AnyObject]? = nil) {
            Log.info("@N>\(name) object=\(object) userInfo=\(userInfo)")
            async {
                notificationCenter.postNotificationName(self.name, object: object, userInfo: userInfo)
            }
        }

        public func addObserver(observer: AnyObject, selector: Selector, sender object: AnyObject? = nil) {
            Log.info("@N+\(name) \(selector)@\(observer)")
            notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
        }

        public func removeObserver(observer: AnyObject, sender object: AnyObject? = nil) {
            Log.info("@N-\(name) \(observer)")
            notificationCenter.removeObserver(observer, name: name, object: object)
        }
    }

    public static func removeAll(forObserver observer: AnyObject) {
        Log.info("@N#\(observer)")
        notificationCenter.removeObserver(observer)
    }
}