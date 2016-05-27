//
//  URLCache.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public class LDURLCache: NSURLCache {
    
    public static var cacheFolder = "URLCache" // The folder in the Documents folder where cached files will be saved
    public static var memoryCapacity = 16 * 1024 * 1024 // The maximum memory size that will be cached
    public static var diskCapacity = 256 * 1024 * 1024 // The maximum file size that will be cached
    public static var filter: (request: NSURLRequest) -> Bool = { _ in return true }
    
    private static var cacheDirectory: String!
    
    // Activate LDURLCache
    public class func activate() {
        // set caching paths
        let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        cacheDirectory = NSURL(fileURLWithPath: cachePath).URLByAppendingPathComponent(cacheFolder).absoluteString
        let urlCache = LDURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: cacheDirectory)
        NSURLCache.setSharedURLCache(urlCache)
    }
    
    // Will be called by a NSURLConnection when it's wants to know if there is something in the cache.
    public override func cachedResponseForRequest(request: NSURLRequest) -> NSCachedURLResponse? {
        guard let url = request.URL else {
            Log.error("CACHE not allowed for nil URLs")
            return nil
        }
        
        let absoluteString = url.absoluteString
        if absoluteString.isEmpty {
            Log.error("CACHE not allowed for empty URLs")
            return nil
        }
        
        if !LDURLCache.filter(request: request) {
            Log.error("CACHE skipped because of filter")
            return nil
        }
        
        if request.cachePolicy == .ReloadIgnoringCacheData && !Reachability.isReachable() || absoluteString.hasPrefix("file:") || absoluteString.hasPrefix("data:") {
            Log.warn("CACHE not allowed for \(url)")
            return nil
        }
        
        let storagePath = LDURLCache.storagePathForRequest(request, rootPath: LDURLCache.cacheDirectory)
        if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
            //Log.warn("CACHE not found \(storagePath) for \(url.absoluteString)")
            return nil
        }
        
        // Read object from file
        if let response = NSKeyedUnarchiver.unarchiveObjectWithFile(storagePath) as? NSCachedURLResponse {
            //Log.info("Returning cached data from \(storagePath) for \(url.absoluteString)");
            
            // I have to find out the difrence. For now I will let the developer checkt which version to use
            //if LDURLCache.RECREATE_CACHE_RESPONSE {
            //// This works for most sites, but aperently not for the game as in the alternate url you see in ViewController
            //let r = NSURLResponse(URL: response.response.URL!, MIMEType: response.response.MIMEType, expectedContentLength: response.data.length, textEncodingName: response.response.textEncodingName)
            //return NSCachedURLResponse(response: r, data: response.data, userInfo: response.userInfo, storagePolicy: .Allowed)
            //}
            // This works for the game, but not for my site.
            return response
        } else {
            Log.error("The file is probably not put in the local path using NSKeyedArchiver \(storagePath)");
        }
        return nil
    }
    
    // Will be called by NSURLConnection when a request is complete.
    public override func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest) {
        if !LDURLCache.filter(request: request) {
            return
        }
        if let httpResponse = cachedResponse.response as? NSHTTPURLResponse {
            if httpResponse.statusCode >= 400 {
                //Log.warn("CACHE Do not cache error \(httpResponse.statusCode) page for : \(request.URL) \(httpResponse.debugDescription)");
                return
            }
        }
        
        let storagePath = LDURLCache.storagePathForRequest(request, rootPath: LDURLCache.cacheDirectory)
        if storagePath.isEmpty {
            Log.error("Error building cache storage path")
        }
        let storageDirectory = NSString(string: storagePath).stringByDeletingLastPathComponent
        do {
            //Log.info("Creating cache directory \(storageDirectory)");
            try NSFileManager.defaultManager().createDirectoryAtPath(storageDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            Log.error("Error creating cache directory \(storageDirectory)");
            Log.error("Error \(error.debugDescription)");
        }
        
        if cachedResponse.response.MIMEType?.hasPrefix("image/") == true {
            if NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
                //Log.warn("CACHE not rewriting stored image file for \(request.URL!.absoluteString)");
                return
            }
        }
        
        if let previousResponse = NSKeyedUnarchiver.unarchiveObjectWithFile(storagePath) as? NSCachedURLResponse {
            if previousResponse.data == cachedResponse.data {
                //Log.info("CACHE not rewriting stored file for \(request.URL!.absoluteString)");
                return
            }
        }
        
        // save file
        //Log.info("Writing data to \(storagePath) for \(request.URL!.absoluteString)");
        if !NSKeyedArchiver.archiveRootObject(cachedResponse, toFile: storagePath) {
            Log.error("Could not write file to cache");
        } else {
            //Log.info("CACHE save file to Cache  : \(storagePath)");
            // prevent iCloud backup
            if !LDURLCache.addSkipBackupAttributeToItemAtURL(NSURL(fileURLWithPath: storagePath)) {
                Log.warn("Could not set the do not backup attribute");
            }
        }
    }
    
    // return the path if the file for the request is in the PreCache or Cache.
    static func storagePathForRequest(request: NSURLRequest) -> String? {
        var storagePath: String? = LDURLCache.storagePathForRequest(request, rootPath: LDURLCache.cacheDirectory)
        if !NSFileManager.defaultManager().fileExistsAtPath(storagePath ?? "") {
            storagePath = nil
        }
        return storagePath;
    }
    
    // build up the complete storrage path for a request plus root folder.
    static func storagePathForRequest(request: NSURLRequest, rootPath: String) -> String {
        if let urlString  = request.URL?.absoluteString {
            let hash = "\(urlString.md5)\(urlString.sha1)".md5
            var localUrl = "\(rootPath)\(hash[0])/\(hash[1...2])/\(hash[3..<32])"
            if localUrl.hasPrefix("file:/") {
                localUrl = localUrl.substringFromIndex(localUrl.startIndex.advancedBy(6))
            }
            localUrl = localUrl.stringByReplacingOccurrencesOfString("//", withString: "/")
            localUrl = localUrl.stringByReplacingOccurrencesOfString("//", withString: "/")
            return localUrl
        }
        return ""
    }
    
    static func addSkipBackupAttributeToItemAtURL(url: NSURL) -> Bool {
        do {
            try url.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
            return true
        } catch _ as NSError {
            Log.error("ERROR: Could not set 'exclude from backup' attribute for file \(url.absoluteString)")
        }
        return false
    }
    
}