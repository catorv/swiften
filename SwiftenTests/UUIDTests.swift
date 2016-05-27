//
//  UUIDTests.swift
//  Swiften
//
//  Created by Cator Vee on 5/24/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import XCTest
@testable import Swiften

class UUIDTests: XCTestCase {

    func testUUID() {
        let uuid = UDID.UUIDString
        XCTAssertEqual(uuid.length, 32)

        var uuids: [String] = []
        for _ in 0..<10 {
            let uuid = UDID.UUIDString
            XCTAssertFalse(uuids.contains(uuid))
            uuids.append(uuid)
        }
    }
    
    func testUDID() {
        let udid1 = UDID.UDIDString
        XCTAssertEqual(udid1.length, 32)
        
        let udid2 = UDID.UDIDString
        XCTAssertEqual(udid1, udid2)
    }

}
