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
    
    let name = "WEBVIEWSERVICE"
    let serviceNameKey = "@NAME"
    
    public var embedService: EmbedService!
    public weak var webView: WebView!
    
    override init() {
      super.init()
      self.embedService = EmbedService(userContentController: self)
      self.add(self, name: name)
			// 兼容旧版本
			self.add(self, name: "__AHA_JSSDK")
    }
    
    required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
      if message.name == name {
        if let body = message.body as? String {
          let options = JSON(parseJSON: body)
          if let serviceName = options[serviceNameKey].string, !serviceName.isEmpty {
            embedService.process(serviceName, options: options)
          }
        }
			} else if message.name == "__AHA_JSSDK" {
				// 兼容旧版本
				if let body = message.body as? String {
					let options = JSON(parseJSON: body)
					if let serviceName = options["__AHA__METHOD__NAME__"].string, !serviceName.isEmpty {
						embedService.process(serviceName, options: options)
					}
				}
			}
    }
		
  }
	
}
