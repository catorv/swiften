//
//  StringifyTests.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import XCTest
@testable import Swiften
import SwiftyJSON

class StringifyTests: XCTestCase {

    func testJSON() {
        let str = "{\"key\":\"value中文emoji😃\"}"
        let json = JSON(dictionaryLiteral: ("key", "value中文emoji😃"))
        XCTAssertEqual(str, json.jsonString)
        XCTAssertEqual(json, str.json)
    }

    func testNSData() {
        let str1 = "123中文"
        let data1 = str1.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertEqual(str1.data, data1)
    }
    
    func testInt() {
        let str1 = "123"
        let str2 = "123a"
        let str3 = "a123"
        
        let int0: Int = 0
        let int123: Int = 123
        
        XCTAssertEqual(str1.integer, int123)
        XCTAssertEqual(str2.integer, int123)
        XCTAssertEqual(str3.integer, int0)
    }
    
    func testFloat() {
        let str1 = "123.45"
        let str2 = "123.45a"
        let str3 = "a123.45"
        
        let float0: Float = 0
        let float123: Float = 123.45
        
        XCTAssertEqual(str1.float, float123)
        XCTAssertEqual(str2.float, float123)
        XCTAssertEqual(str3.float, float0)
    }
    
    func testDouble() {
        let str1 = "123.45"
        let str2 = "123.45a"
        let str3 = "a123.45"
        
        let double0: Double = 0
        let double123: Double = 123.45
        
        XCTAssertEqual(str1.double, double123)
        XCTAssertEqual(str2.double, double123)
        XCTAssertEqual(str3.double, double0)
    }
    
    func testBool() {
        for str in ["true", "True", "yes", "YES", "1", "2", "3", "4", "5", "6", "7", "8", "ttt"] {
            XCTAssertTrue(str.bool)
        }
        XCTAssertFalse("false".bool)
    }
}
