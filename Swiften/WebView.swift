//
//  WebView.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import WebKit

public class WebView : UIView {
    
    // MARK:- statics
    
    private static var _userAgent: String!
    public static var userAgent: String {
        if _userAgent == nil {
            _userAgent = UIWebView().stringByEvaluatingJavaScriptFromString("navigator.userAgent") ?? ""
        }
        let netType = Reachability.networkStatus.description
        let ua = "\(_userAgent) Aha/\(App.version) NetType/\(netType) Language/\(App.lang)"
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": ua])
        return ua
    }
    
    public static var defaultConfiguration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.userContentController = UserContentController()
        return config
    }
    
    // MARK: properties
    
    private var loadingProgressBar = UIProgressView()
    public var loadingProgressBarHidden: Bool = false {
        didSet { loadingProgressBar.hidden = loadingProgressBarHidden }
    }
    
    public weak var serviceDelegate: WebViewServiceDelegate?
    public weak var navigationDelegate: WKNavigationDelegate?
    public weak var UIDelegate: WKUIDelegate?
    public var webView: WKWebView!
    
    // MARK: - init
    
    convenience init() {
        self.init(frame: CGRectZero, configuration: WebView.defaultConfiguration)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, configuration: WebView.defaultConfiguration)
    }
    
    public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame)
        self.setup(configuration)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup(WebView.defaultConfiguration)
    }
    
    private func setup(config: WKWebViewConfiguration) {
        // Setup WebView
        webView = WKWebView(frame: bounds, configuration: config)
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(webView)
        
        // Setup User Content Controller
        if let userContentController = webView.configuration.userContentController as? UserContentController {
            userContentController.webView = self
        }
        
        // Setup User Agent
        if #available(iOS 9.0, *) {
            webView.customUserAgent = WebView.userAgent
        }
        
        // Setup Loading ProgressBar
        self.addSubview(loadingProgressBar)
        loadingProgressBar.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 1)
        loadingProgressBar.autoresizingMask = [.FlexibleWidth]
        
        // Setup Navigation Delegate
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        // Setup UI Delegate
        webView.UIDelegate = self
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    // MARK: - Custom Methods
    
    func loadURLString(urlString: String) -> WKNavigation? {
        if let url = NSURL(string: urlString) {
            return loadRequest(NSURLRequest(URL: url))
        }
        return nil
    }
    
    // MARK: - Observe Value For KeyPath
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            self.loadingProgressBar.progress = Float(0.1 + self.webView.estimatedProgress * 0.9)
        }
    }
    
}

// MARK: - WKWebView Proxy

extension WebView {
    
    // MARK: The properties of WKWebView
    
    public var canGoBack: Bool { return webView.canGoBack }
    public var canGoForward: Bool { return webView.canGoForward }
    public var title: String? { return webView.title }
    public var loading: Bool { return webView.loading }
    public var URL: NSURL? { return webView.URL }
    
    // MARK: - The methods of WKWebView
    
    public func reload() -> WKNavigation? {
        return webView.reload()
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

// MARK: - WKNavigationDelegate Proxy

extension WebView: WKNavigationDelegate {
    //public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        //navigationDelegate?.webView?(webView, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
    //}
    
    //public func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        //navigationDelegate?.webView?(webView, decidePolicyForNavigationResponse: navigationResponse, decisionHandler: decisionHandler)
    //}
    
    public func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Log.info("webview: \(webView.URL!.absoluteString)")
        if !loadingProgressBarHidden {
            loadingProgressBar.hidden = false
            loadingProgressBar.progress = 0.1
        }
        navigationDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }
    
    public func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        navigationDelegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }
    
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        Log.error("webview didFailProvisionalNavigation:\(error)")
        navigationDelegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        loadingProgressBar.hidden = true
        loadingProgressBar.progress = 1
        navigationDelegate?.webView?(webView, didFinishNavigation: navigation!)
    }
    
    public func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        navigationDelegate?.webView?(webView, didCommitNavigation: navigation)
    }
    
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        navigationDelegate?.webView?(webView, didFailNavigation: navigation, withError: error)
    }
    
    //public func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        //navigationDelegate?.webView?(webView, didReceiveAuthenticationChallenge: challenge, completionHandler: completionHandler)
    //}
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(webView: WKWebView) {
        navigationDelegate?.webViewWebContentProcessDidTerminate?(webView)
    }
}

// MARK: - WKUIDelegate Proxy

extension WebView: WKUIDelegate {
    
    public func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return UIDelegate?.webView?(webView, createWebViewWithConfiguration: configuration, forNavigationAction: navigationAction, windowFeatures: windowFeatures)
    }
    
    @available(iOS 9.0, *)
    public func webViewDidClose(webView: WKWebView) {
        UIDelegate?.webViewDidClose?(webView)
    }
    
    public func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        alert(message) { _ in completionHandler() }
    }

    public func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        confirm(message) { completionHandler($0) }
    }

    public func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt message: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        prompt(message, title: nil, text: defaultText) { completionHandler($0) }
    }
}