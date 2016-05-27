//
//  ReachabilityTests.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import XCTest
@testable import Swiften

class ReachabilityTests: XCTestCase {

    func testReachable() {
        XCTAssertEqual(Reachability.networkStatus, Reachability.NetworkStatus.reachableViaWiFi)
        
        XCTAssertEqual(Reachability.NetworkStatus.reachableViaWiFi.description, "WiFi")
        XCTAssertEqual(Reachability.NetworkStatus.reachableViaWWAN.description, "WWAN")
        XCTAssertEqual(Reachability.NetworkStatus.notReachable.description, "NoConnection")
        
        XCTAssertTrue(Reachability.isReachable())
        XCTAssertTrue(Reachability.isReachableViaWiFi())
        XCTAssertFalse(Reachability.isReachableViaWWAN())
    }

}
