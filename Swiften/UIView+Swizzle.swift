//
//  UIView+Swizzle.swift
//  Swiften
//
//  Created by Cator Vee on 5/27/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

extension UIView {
    
    func __swizzed_init(frame frame: CGRect) -> UIView {
        let view = self.__swizzed_init(frame: frame)
        view.setupView()
        return view
    }
    
    func swizzed_init(coder aDecoder: NSCoder) -> UIView? {
        if let view = self.swizzed_init(coder: aDecoder) {
            view.setupView()
            return view
        }
        return nil
    }
    
    /// 空方法，用于重新设置view的内容
    func setupView() {
        // nothing
    }
    
    public class func swizzles_swiften() {
        struct Static {
            static var token: dispatch_once_t = 0;
        }
        
        // make sure this isn't a subclass
        if self !== UIView.self {
            return
        }
        
        // 只执行一次
        dispatch_once(&Static.token) {
            Swizzler.swizzleMethod(#selector(UIView.init(frame:)), with: #selector(UIView.__swizzed_init(frame:)), forClass: UIView.self)
            Swizzler.swizzleMethod(#selector(UIView.init(coder:)), with: #selector(UIView.swizzed_init(coder:)), forClass: UIView.self)
        }
    }
    
    override public class func initialize() {
        super.initialize()
        swizzles_swiften()
    }
}