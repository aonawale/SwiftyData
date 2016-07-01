//
//  SwiftDataTests.swift
//  SwiftDataTests
//
//  Created by Ahmed Onawale on 6/28/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import XCTest
import CoreData
@testable import SwiftData

class Person: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var age: Int64
}

extension Person: KeyCodeable {
    enum Key: String {
        case name
        case age
    }
}

class SwiftDataTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        Person.destroyAll()
    }
    
    func testCreateEmptyObject() {
        let person = Person.create()
        XCTAssertNotNil(person)
        XCTAssertEqual(person.name, "")
        XCTAssertEqual(person.age, 0)
    }
    
    func testUpdateObject() {
        let person = Person.create()
        person.update([.name: "Ahmed", .age: 18])
        XCTAssertEqual(person.name, "Ahmed")
        XCTAssertEqual(person.age, 18)
    }

    func testCreateObjectWithProperties() {
        let person = Person.create([.name: "Onawale", .age: 20])
        XCTAssertEqual(person.name, "Onawale")
        XCTAssertEqual(person.age, 20)
        let prop = person.get([.name, .age])
        XCTAssertEqual(prop["name"] as? String, "Onawale")
        XCTAssertEqual(prop["age"] as? Int, 20)
    }
    
    func testFindAllObjects() {
        _ = Person.create([.name: "Ahmed", .age: 10])
        _ = Person.create([.name: "Onawale", .age: 28])
        _ = Person.create([.name: "Ayo", .age: 40])
        let people = Person.findAll()
        XCTAssertEqual(people.count, 3)
    }
    
    func testFindObjectById() {
        let id = Person.create([.name: "Ahmed", .age: 29]).objectID
        let person = Person.findById(id)
        XCTAssertNotNil(person)
        XCTAssertEqual(person?.name, "Ahmed")
        XCTAssertEqual(person?.age, 29)
    }
    
    func testFindObjectByNSURL() {
        let url = Person.create([.name: "Ahmed", .age: 29]).objectID.URIRepresentation()
        let person = Person.findByNSURL(url)
        XCTAssertNotNil(person)
        XCTAssertEqual(person?.name, "Ahmed")
        XCTAssertEqual(person?.age, 29)
    }
    
    func testDestroyObject() {
        let person = Person.create()
        XCTAssertNotNil(person)
        person.destroy()
        XCTAssertNil(Person.findById(person.objectID))
    }
    
    func testDestroyAllObjects() {
        _ = Person.create([.name: "Ahmed", .age: 10])
        _ = Person.create([.name: "Onawale", .age: 28])
        _ = Person.create([.name: "Ayo", .age: 40])
        XCTAssertEqual(Person.findAll().count, 3)
        Person.destroyAll()
        XCTAssertEqual(Person.findAll().count, 0)
    }
    
    func testSaveContext() {
        XCTAssertFalse(Person.save())
        let person = Person.create([.name: "Ahmed", .age: 33])
        XCTAssertTrue(person.save())
        XCTAssertFalse(person.save())
        person.setProperties([.name: "Onawale"])
        XCTAssertTrue(Person.save())
    }
    
    func testBulkCreationOfObjects() {
        let people = Person.bulkCreate([.name: "Ayo", .age: 19], [.name: "Ahmed", .age: 29], [.name: "Onawale", .age: 32])
        XCTAssertEqual(people.count, 3)
    }
    
    func testReloadObject() {
        let person = Person.create([.name: "Ahmed", .age: 33])
        XCTAssertTrue(person.save())
        person.update([.name: "Onawale", .age: 40])
        XCTAssertEqual(person.name, "Onawale")
        XCTAssertEqual(person.age, 40)
        person.reload()
        XCTAssertNotEqual(person.name, "Onawale")
        XCTAssertNotEqual(person.age, 40)
        XCTAssertEqual(person.name, "Ahmed")
        XCTAssertEqual(person.age, 33)
    }
    
    func testQueryObjects() {
        _ = Person.bulkCreate([.name: "Ayo", .age: 19], [.name: "Ahmed", .age: 29], [.name: "Onawale", .age: 32])
        
        let lessThan30 = Person.find(where: "age < %@", 30)
        XCTAssertEqual(lessThan30.count, 2)
        
        let ahmeds = Person.find(where: "name == %@ AND age == %@", "Ahmed", 29)
        XCTAssertEqual(ahmeds.count, 1)
        XCTAssertEqual(ahmeds.first?.name, "Ahmed")
        
        let onawales = Person.find(where: [.name: "Onawale", .age: 32])
        XCTAssertEqual(onawales.count, 1)
        XCTAssertEqual(onawales.first?.name, "Onawale")
        XCTAssertEqual(onawales.first?.age, 32)
        
        let predicate = NSPredicate(format: "age > 18")
        let greaterThan18 = Person.find(where: predicate)
        XCTAssertEqual(greaterThan18.count, 3)
    }
    
    func testFindOneObject() {
        _ = Person.bulkCreate([.name: "Ayo", .age: 19], [.name: "Ahmed", .age: 29], [.name: "Onawale", .age: 32])
        let ahmed = Person.findOne(where: "name == %@", "Ahmed")
        XCTAssertEqual(ahmed.name, "Ahmed")
        XCTAssertEqual(ahmed.age, 29)
        
        let ayo = Person.findOne(where: "age < %@", 20)
        XCTAssertEqual(ayo.name, "Ayo")
        XCTAssertEqual(ayo.age, 19)
    }
}
