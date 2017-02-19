//
//  PortraitViewController.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

class PortraitViewController: UIViewController {
  
  override var shouldAutorotate : Bool {
    return false
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return .portrait
  }
  
}
