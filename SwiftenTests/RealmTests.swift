//
// Created by Cator Vee on 2019-03-07.
// Copyright (c) 2019 Cator Vee. All rights reserved.
//

import XCTest
@testable import Swiften
import RealmSwift

@objcMembers
final class TestObject: Object, ManagedObject {
    static let om = RealmObjectManager<TestObject>(realm: Realm.shared)
    
    dynamic var id = ""
    dynamic var name = ""
    dynamic var age = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class RealmTests: XCTestCase {

    func testRealm() {
        var obj = TestObject()
        obj.id = "object-id"
        obj.name = "Cator Vee"
        obj.age = 18
        obj.save()
        
        XCTAssertEqual(obj, TestObject.get(by: "object-id"))
        
        obj.delete()
        
        XCTAssertNil(TestObject.get(by: "object-id"))
        
        obj = TestObject()
        obj.id = "object-id"
        obj.name = "Cator Vee"
        obj.age = 18
        obj.save()

        XCTAssertEqual(obj, TestObject.get(by: "object-id"))
        
        let obj2 = TestObject()
        obj2.id = "object-id"
        obj2.name = "Cator Vee"
        obj2.age = 18
        
        obj.write {
            obj.age = 19
            obj.write {
                obj.age = 20
            }
            obj2.write {
                obj2.age = 21
            }
        }
        
        TestObject.deleteAll()
        
        XCTAssertNil(TestObject.get(by: "object-id"))
    }

}
