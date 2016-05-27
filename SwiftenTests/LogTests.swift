//
//  LogTests.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import XCTest
@testable import Swiften

class LogTests: XCTestCase {

    func testLevel() {
        XCTAssertTrue(Log.LEVEL_ALL & Log.LEVEL_DEBUG != 0)
        XCTAssertTrue(Log.LEVEL_ALL & Log.LEVEL_INFO != 0)
        XCTAssertTrue(Log.LEVEL_ALL & Log.LEVEL_WARN != 0)
        XCTAssertTrue(Log.LEVEL_ALL & Log.LEVEL_ERROR != 0)
    }
    
}
