//
//  NetworkManager.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

open class NetworkManager {
  open static var defaultManager: Alamofire.SessionManager!
  
  open static let sharedCookieStorage = HTTPCookieStorage.shared
  
  open static func initNetworkManager(sserverTrustPolicie serverTrustPolicies: [String: ServerTrustPolicy]? = nil) {
    
    URLCache.activate()
    
    var serverTrustPolicyManager: ServerTrustPolicyManager? = nil
    if let policies = serverTrustPolicies {
      serverTrustPolicyManager = ServerTrustPolicyManager(policies: policies)
    }
    
    // 初始化图片下载器
    let configuration = NetworkManager.defaultSessionConfiguration
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    let manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
    let sharedImageDownloader = ImageDownloader(sessionManager: manager)
    UIImageView.af_sharedImageDownloader = sharedImageDownloader
    UIButton.af_sharedImageDownloader = sharedImageDownloader
    
    // 初始化默认网络请求
    NetworkManager.defaultManager = Alamofire.SessionManager(
      configuration: NetworkManager.defaultSessionConfiguration,
      serverTrustPolicyManager: serverTrustPolicyManager
    )
  }
  
  static func removeAllCookies() {
    if let cookies = sharedCookieStorage.cookies {
      for cookie in cookies {
        sharedCookieStorage.deleteCookie(cookie)
      }
    }
  }
}

// MARK: - Default Session Configuration

extension NetworkManager {
  public static var defaultSessionConfiguration: URLSessionConfiguration {
    var headers = Alamofire.SessionManager.defaultHTTPHeaders
    headers["Cache-Control"] = "private"
    headers["User-Agent"] = WebView.userAgent
    
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30 // 网络超时时间
    configuration.httpAdditionalHeaders = headers
    configuration.httpCookieStorage = sharedCookieStorage
    configuration.urlCache = Foundation.URLCache.shared
    
    return configuration
  }
}
