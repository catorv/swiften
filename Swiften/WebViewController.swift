//
//  WebViewController.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

open class WebViewController: UIViewController {
  @IBOutlet open var webView: WebView!
  
  fileprivate var url: Foundation.URL!
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    if webView == nil {
      webView = WebView(frame: view.bounds)
      view.addSubview(webView!)
    }
    
    if let url = url {
      load(from: url)
      self.url = nil
    }
  }
  
  open func load(from url: Foundation.URL) {
    if webView != nil {
      load(URLRequest(url: url))
    } else {
      self.url = url
    }
  }
  
  open func load(_ request: URLRequest) {
    let _ = webView.loadRequest(request)
  }
  
  // MARK: - Navigation
  
  open func close() {
    self.hide(animated: true)
  }
  
  open func back() {
    guard let webView = webView?.webView else { return }
    if webView.canGoBack {
      webView.goBack()
    } else {
      close()
    }
  }
  
  open func forward() {
    guard let webView = webView?.webView else { return }
    if webView.canGoForward {
      webView.goForward()
    }
  }
  
}

extension WebViewController {
  public class func open(urlString: String?) {
    guard let urlString = urlString else {
      return
    }
    open(url: URL(string: urlString))
  }
  
  public class func open(url: URL?) {
    guard let url = url else {
      return
    }
    let controller = WebViewController()
    controller.load(from: url)
    controller.hidesBottomBarWhenPushed = true
    UIViewController.show(viewController: controller, animated: true)
  }
}
