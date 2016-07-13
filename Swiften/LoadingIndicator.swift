//
// Created by Cator Vee on 7/10/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation

public class LoadingIndicator {
    private var count = 0
    private var view: UIView?

    public func startLoading() {
        guard let window = UIApplication.sharedApplication().keyWindow else {
            return
        }
        async {
            if self.count == 0 {
                if self.view == nil {
                    self.view = UIView(frame: window.bounds)
                } else {
                    self.view!.removeFromSuperview()
                }

                window.addSubview(self.view!)
            }
            self.count += 1
        }
    }

    public func stopLoading() {
        async {
            self.count -= 1
            if self.count <= 0 {
                self.count = 0
                guard let loadingView = self.view else {
                    return
                }
                loadingView.removeFromSuperview()
            }
        }
    }
}
