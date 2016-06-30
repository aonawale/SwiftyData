//
//  SwiftDataTests.swift
//  SwiftDataTests
//
//  Created by Ahmed Onawale on 6/28/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
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
    
    func testEmptyObject() {
        let person = Person.create()
        XCTAssertNotNil(person)
        XCTAssertEqual(person.name, "")
        XCTAssertEqual(person.age, 0)
    }
    
    func testUpdateObject() {
        let person = Person.create()
        person.setProperties([.name: "Ahmed", .age: 18])
        XCTAssertEqual(person.name, "Ahmed")
        XCTAssertEqual(person.age, 18)
    }

    func testCreateObjectWithProperties() {
        let person = Person.create([.name: "Onawale", .age: 20])
        XCTAssertEqual(person.name, "Onawale")
        XCTAssertEqual(person.age, 20)
        let prop = person.getProperties([.name, .age])
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
}
