//
//  WebViewController.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public class WebViewController: UIViewController {
    @IBOutlet public var webView: WebView!

    private var URL: NSURL!

    override public func viewDidLoad() {
        super.viewDidLoad()

        if webView == nil {
            webView = WebView(frame: view.bounds)
            view.addSubview(webView!)
        }

        if let URL = URL {
            load(fromURL: URL)
            self.URL = nil
        }
    }

    public func load(fromURL URL: NSURL) {
        if let webView = webView {
            load(fromRequest: NSURLRequest(URL: URL))
        } else {
            self.URL = URL
        }
    }

    public func load(fromRequest request: NSURLRequest) {
        webView.loadRequest(request)
    }

    // MARK: - Navigation

    public func close() {
        self.closeViewControllerAnimated(true)
    }

    public func back() {
        guard let webView = webView?.webView else { return }
        if webView.canGoBack {
            webView.goBack()
        } else {
            close()
        }
    }

    public func forward() {
        guard let webView = webView?.webView else { return }
        if webView.canGoForward {
            webView.goForward()
        }
    }

}

extension WebViewController {
    public class func open(urlString urlString: String?) {
        guard let urlString = urlString else { return }
        open(URL: NSURL(string: urlString))
    }

    public class func open(URL URL: NSURL?) {
        guard let URL = URL else { return }
        let controller = WebViewController()
        controller.load(fromURL: URL)
        controller.hidesBottomBarWhenPushed = true
        UIViewController.showViewController(controller, animated: true)
    }
}