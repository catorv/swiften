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

public class NetworkManager {
    public static var defaultManager: Alamofire.Manager!
    
    public static let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    
    public static func initNetworkManager(serverTrustPolicies: [String: ServerTrustPolicy]? = nil) {
        
        LDURLCache.activate()
        
        var serverTrustPolicyManager: ServerTrustPolicyManager? = nil
        if let policies = serverTrustPolicies {
            serverTrustPolicyManager = ServerTrustPolicyManager(policies: policies)
        }
        
        // 初始化图片下载器
        let configuration = NetworkManager.defaultSessionConfiguration
        configuration.requestCachePolicy = .ReturnCacheDataElseLoad
        let manager = Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
        let sharedImageDownloader = ImageDownloader(sessionManager: manager)
        UIImageView.af_sharedImageDownloader = sharedImageDownloader
        UIButton.af_sharedImageDownloader = sharedImageDownloader
        
        // 初始化默认网络请求
        NetworkManager.defaultManager = Alamofire.Manager(
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
    public static var defaultSessionConfiguration: NSURLSessionConfiguration {
        var headers = Alamofire.Manager.defaultHTTPHeaders
        headers["Cache-Control"] = "private"
        headers["User-Agent"] = WebView.userAgent
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 30 // 网络超时时间
        configuration.HTTPAdditionalHeaders = headers
        configuration.HTTPCookieStorage = sharedCookieStorage
        configuration.URLCache = NSURLCache.sharedURLCache()
        
        return configuration
    }
}