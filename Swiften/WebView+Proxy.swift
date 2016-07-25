//
// Created by Cator Vee on 7/26/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation
import WebKit

extension WebView {

    // MARK: The properties of WKWebView

    public var canGoBack: Bool {
        return webView.canGoBack
    }
    public var canGoForward: Bool {
        return webView.canGoForward
    }
    public var title: String? {
        return webView.title
    }
    public var loading: Bool {
        return webView.loading
    }
    public var URL: NSURL? {
        return webView.URL
    }

    // MARK: - The methods of WKWebView

    public func reload() -> WKNavigation? {
        return webView.reload()
    }

    public func reloadFromOrigin() -> WKNavigation? {
        return webView.reloadFromOrigin()
    }

    public func loadRequest(request: NSURLRequest) -> WKNavigation? {
        return webView.loadRequest(request)
    }

    public func loadHTMLString(string: String, baseURL: NSURL?) -> WKNavigation? {
        return webView.loadHTMLString(string, baseURL: baseURL)
    }

    public func stopLoading() {
        webView.stopLoading()
    }

    public func goBack() -> WKNavigation? {
        return webView.goBack()
    }

    public func goForward() -> WKNavigation? {
        return webView.goForward()
    }

    public func evaluateJavaScript(javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?) {
        webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
}