//
//  HttpClient.swift
//  Swiften
//
//  Created by Cator Vee on 24/02/2017.
//  Copyright © 2017 Cator Vee. All rights reserved.
//

import Foundation
import Alamofire

public struct HttpClient {

  public static var `default` = SessionManager.default
	public static var defaultEncoding: ParameterEncoding = URLEncoding.default
	
	public static var codeFieldName			= "code"
	public static var messageFieldName	= "msg"
	public static var errorFieldName		= "errmsg"
	public static var tokenFieldName		= "token"
  
  public static func initHttpClient(configuration: URLSessionConfiguration = .default,
                                    delegate: SessionDelegate = SessionDelegate(),
                                    serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
    if configuration.httpAdditionalHeaders == nil {
      configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    }
    if configuration.httpAdditionalHeaders!["User-Agent"] == nil {
      configuration.httpAdditionalHeaders!["User-Agent"] = WebView.userAgent
    }
    if configuration.urlCache == nil {
      configuration.urlCache = URLCache.shared
    }
  }

}
