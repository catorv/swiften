//
// Created by Cator Vee on 7/26/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation
import WebKit

extension WebView: WKUIDelegate {

    public func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return UIDelegate?.webView?(webView, createWebViewWithConfiguration: configuration, forNavigationAction: navigationAction, windowFeatures: windowFeatures)
    }

    @available(iOS 9.0, *)
    public func webViewDidClose(webView: WKWebView) {
        UIDelegate?.webViewDidClose?(webView)
    }

    public func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        alert(message, completion: completionHandler)
    }

    public func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        confirm(message, completion: completionHandler)
    }

    public func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt message: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        prompt(message, title: nil, text: defaultText, completion: completionHandler)
    }
}