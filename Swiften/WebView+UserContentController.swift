//
//  WebView+UserContentController.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import WebKit
import SwiftyJSON

extension WebView {
    
    public class UserContentController : WKUserContentController, WKScriptMessageHandler {
        
        let name = "__AHA_JSSDK"
        let methodKey = "__AHA__METHOD__NAME__"
        
        var embedService: EmbedService!
        weak var webView: WebView!
        
        override init() {
            super.init()
            self.embedService = EmbedService(userContentController: self)
            self.addScriptMessageHandler(self, name: name)
        }
        
        public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
            if message.name == name {
                if let body = message.body as? String {
                    let options = body.json
                    if let methodName = options[methodKey].string where !methodName.isEmpty {
                        embedService.process(methodName, options: options)
                    }
                }
            }
        }
        
    }
    
}