//
//  UserAgent.swift
//  Swiften
//
//  Created by Cator Vee on 11/03/2017.
//  Copyright © 2017 Cator Vee. All rights reserved.
//

import Foundation
import WebKit
import Reachability

public struct UserAgent {
    private static var browserUserAgent: String!
    public static var string: String {
        if browserUserAgent == nil {
            prepare()
        }
        
        let netType: String
        if let reachabilityStatus = Reachability()?.connection {
            switch reachabilityStatus {
            case .wifi:
                netType = "WiFi"
            case .cellular:
                netType = "Cellular"
            case .none:
                netType = "None"
            }
        } else {
            netType = "Unknown"
        }
        
        return "\(browserUserAgent!) \(App.name)/\(App.version) NetType/\(netType) Language/\(App.lang)"
    }
    
    public static func apply(_ webView: WKWebView) {
        let userAgentString = UserAgent.string
        UserDefaults.standard.register(defaults: ["UserAgent": userAgentString])
        if #available(iOS 9.0, *) {
            webView.customUserAgent = userAgentString
        }
    }
    
    public static func prepare() {
        if browserUserAgent == nil {
            browserUserAgent = ""
            WKWebView().evaluateJavaScript("navigator.userAgent") { result, error in
                browserUserAgent = result as? String ?? ""
            }
        }
    }
}
