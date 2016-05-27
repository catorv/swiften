//
//  App.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public struct App {
    
    public static var bundle: NSBundle {
        return NSBundle.mainBundle()
    }
    
    public static var version: String {
        return bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? ""
    }
    
    public static var buildNumber: Int {
        return Int(bundle.objectForInfoDictionaryKey("CFBundleVersion") as? String ?? "0") ?? 0
    }
    
    public static var lang: String {
        return bundle.preferredLocalizations.first ?? ""
    }
    
}