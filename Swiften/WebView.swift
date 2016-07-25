//
//  WebView.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import WebKit

public class WebView: UIView {

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

    public static var defaultProcessPool = WKProcessPool()
    public static var defaultConfiguration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.processPool = defaultProcessPool
        config.userContentController = UserContentController()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 9.0, *) {
            config.websiteDataStore = WKWebsiteDataStore.defaultDataStore()
            config.requiresUserActionForMediaPlayback = false
        } else {
            config.mediaPlaybackRequiresUserAction = false
        }
        return config
    }

    // MARK: properties

    public var loadingProgressBar = UIProgressView()
    public var loadingProgressBarHidden: Bool = false {
        didSet {
            loadingProgressBar.hidden = loadingProgressBarHidden
        }
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

    public required init?(coder aDecoder: NSCoder) {
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

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            self.loadingProgressBar.progress = Float(0.1 + self.webView.estimatedProgress * 0.9)
        }
    }

}