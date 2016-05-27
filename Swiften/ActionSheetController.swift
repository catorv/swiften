//
//  ActionSheetController.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

public class ActionSheetController: UIViewController {

    @IBOutlet public var popupView: UIView!
    var dismissButton: UIButton!

    public func presentOverViewController(viewController: UIViewController) {
        modalPresentationStyle = .OverFullScreen
        view.backgroundColor = UIColor(rgba: 0x00000000)

        dismissButton = UIButton()
        dismissButton.addTarget(self, action: #selector(onDismiss(_:)), forControlEvents: .TouchUpInside)
        dismissButton.frame = view.bounds
        dismissButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.insertSubview(dismissButton, atIndex: 0)

        popupView.alpha = 0
        viewController.presentViewController(self, animated: false) { [weak popupView, weak view] in
            guard let view = view, popupView = popupView else { return }
            let originFrame = popupView.frame
            popupView.frame = CGRect(origin: CGPoint(x: 0, y: view.bounds.size.height), size: originFrame.size)
            UIView.animateWithDuration(0.25, animations: {
                view.backgroundColor = UIColor(rgba: 0x00000066)
                popupView.alpha = 1
                popupView.frame = originFrame
            })
        }
    }

    func onDismiss(sender: UIButton) {
        self.dismissActionSheetController()
    }

    public func dismissActionSheetController(completion: (() -> Void)? = nil) {
        UIView.transitionWithView (self.popupView, duration: 0.25, options: .BeginFromCurrentState, animations: {
            self.view.backgroundColor = UIColor(rgba: 0x00000000)
            self.popupView.alpha = 0
            }, completion: { (finished) in
            self.dismissViewControllerAnimated(false, completion: completion)
        })
    }
}