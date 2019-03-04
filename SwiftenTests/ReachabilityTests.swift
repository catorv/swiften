//
//  ReachabilityTests.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import XCTest
import Swiften
import Reachability

class ReachabilityTests: XCTestCase {
  
  func testReachable() {
    guard let reachability = Reachability() else {
      XCTAssertTrue(false)
      return
    }
    
    XCTAssertEqual(reachability.connection, .wifi)
    
    XCTAssertTrue(reachability.connection != .none)
    XCTAssertTrue(reachability.connection == .wifi)
    XCTAssertFalse(reachability.connection == .cellular)
  }
  
}
