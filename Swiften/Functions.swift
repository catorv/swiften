//
//  Functions.swift
//  Swiften
//
//  Created by Cator Vee on 5/24/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

/// 延迟执行代码
public func delay(seconds: UInt64, task: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), task)
}

/// 异步执行代码块（先非主线程执行，再返回主线程执行）
public func async(backgroundTask: () -> AnyObject!, mainTask: AnyObject? -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        let result = backgroundTask()
        dispatch_sync(dispatch_get_main_queue()) {
            mainTask(result)
        }
    }
}

/// 异步执行代码块（主线程执行）
public func async(mainTask: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), mainTask)
}

/// 顺序执行代码块（在队列中执行）
public func sync(task: () -> Void) {
    dispatch_sync(dispatch_queue_create("com.catorv.LockQueue", nil), task)
}

public func alert(message: String, title: String! = nil, completion: (() -> Void)? = nil) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    controller.addAction(UIAlertAction(title: "我知道了", style: .Default) { action in
        controller.dismissViewControllerAnimated(true, completion: nil)
        completion?()
        })
    UIViewController.topViewController?.presentViewController(controller, animated: true, completion: nil)
}

public func confirm(message: String, title: String! = nil, completion: Bool -> Void) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    controller.addAction(UIAlertAction(title: "否", style: .Cancel) { action in
        controller.dismissViewControllerAnimated(true, completion: nil)
        completion(false)
        })
    controller.addAction(UIAlertAction(title: "是", style: .Default) { action in
        controller.dismissViewControllerAnimated(true, completion: nil)
        completion(true)
        })
    UIViewController.topViewController?.presentViewController(controller, animated: true, completion: nil)
}

public func prompt(message: String, title: String! = nil, text: String! = nil, placeholder: String! = nil, completion: String? -> Void) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    controller.addAction(UIAlertAction(title: "取消", style: .Cancel) { action in
        controller.dismissViewControllerAnimated(true, completion: nil)
        completion(nil)
        })
    controller.addAction(UIAlertAction(title: "确定", style: .Default) { action in
        controller.dismissViewControllerAnimated(true, completion: nil)
        completion(controller.textFields?[0].text ?? "")
        })
    controller.addTextFieldWithConfigurationHandler { textField in
        if let value = text {
            textField.text = value
        }
        if let ph = placeholder {
            textField.placeholder = ph
        }
    }
    UIViewController.topViewController?.presentViewController(controller, animated: true, completion: nil)
}