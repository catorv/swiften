//
//  Notifications.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import Reachability

public struct Notifications {
    
    public typealias Name = NSNotification.Name
    
    public static let notificationCenter = NotificationCenter.default
    
    public static let reachabilityChanged = Proxy(name: .reachabilityChanged)
    
    public class Proxy {
        private let name: Name
        
        public init(name: Name) {
            self.name = name
        }
        
        public convenience init(name: String) {
            self.init(name: Name(name))
        }
        
        public func post(object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
            Log.info("@N>\(name) object=\(String(describing: object)) userInfo=\(String(describing: userInfo))")
            async {
                notificationCenter.post(name: self.name, object: object, userInfo: userInfo)
            }
        }
        
        public func add(observer: Any, selector: Selector, sender object: AnyObject? = nil) {
            Log.info("@N+\(name) \(selector)@\(observer)")
            notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
        }
        
        public func remove(observer: Any, sender object: Any? = nil) {
            Log.info("@N-\(name) \(observer)")
            notificationCenter.removeObserver(observer, name: name, object: object)
        }
    }
    
    public static func removeAll(forObserver observer: Any) {
        Log.info("@N#\(observer)")
        notificationCenter.removeObserver(observer)
    }
}
