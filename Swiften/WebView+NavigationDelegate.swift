//
// Created by Cator Vee on 7/26/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation
import WebKit

extension WebView: WKNavigationDelegate {
    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else {
            decisionHandler(.Cancel)
            return
        }
        let urlString = url.absoluteString
        if urlString!.containsString("//itunes.apple.com/") || !urlString!.hasPrefix("//") && !urlString!.hasPrefix("http:") && !urlString!.hasPrefix("https:") {
            UIApplication.sharedApplication().openURL(url)
            decisionHandler(.Cancel)
        } else if navigationDelegate != nil && navigationDelegate!.respondsToSelector(#selector(WKNavigationDelegate.webView(_:decidePolicyForNavigationAction:decisionHandler:))) {
            navigationDelegate!.webView?(webView, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.Allow)
        }
    }

    public func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        if navigationDelegate != nil && navigationDelegate!.respondsToSelector(#selector(WKNavigationDelegate.webView(_:decidePolicyForNavigationResponse:decisionHandler:))) {
            navigationDelegate!.webView?(webView, decidePolicyForNavigationResponse: navigationResponse, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.Allow)
        }
    }

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

    public func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if navigationDelegate != nil && navigationDelegate!.respondsToSelector(#selector(WKNavigationDelegate.webView(_:didReceiveAuthenticationChallenge:completionHandler:))) {
            navigationDelegate!.webView?(webView, didReceiveAuthenticationChallenge: challenge, completionHandler: completionHandler)
        } else {
            guard let hostName = webView.URL?.host else {
                completionHandler(.CancelAuthenticationChallenge, nil);
                return
            }

            let authenticationMethod = challenge.protectionSpace.authenticationMethod
            if authenticationMethod == NSURLAuthenticationMethodDefault
                    || authenticationMethod == NSURLAuthenticationMethodHTTPBasic
                    || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
                let title = "身份认证"
                let message = "\(hostName)需要您的用户名和密码"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler {
                    $0.placeholder = "用户名"
                }
                alertController.addTextFieldWithConfigurationHandler {
                    $0.placeholder = "密码"
                    $0.secureTextEntry = true
                }
                alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: { _ in
                    let username = alertController.textFields![0].text ?? ""
                    let password = alertController.textFields![1].text ?? ""
                    let credential = NSURLCredential(user: username, password: password, persistence: .None)
                    completionHandler(.UseCredential, credential)
                }))
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { _ in
                    completionHandler(.CancelAuthenticationChallenge, nil)
                }))
                async {
                    UIViewController.topViewController?.presentViewController(alertController, animated: true, completion: nil)
                }
            } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
                completionHandler(.PerformDefaultHandling, nil)
            } else {
                completionHandler(.CancelAuthenticationChallenge, nil)
            }
        }
    }

    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(webView: WKWebView) {
        navigationDelegate?.webViewWebContentProcessDidTerminate?(webView)
    }
}
