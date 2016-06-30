//
//  KeyCodeable.swift
//  SwiftData
//
//  Created by Ahmed Onawale on 6/29/16.
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

import CoreData

public protocol KeyCodeable {
    associatedtype Key: RawRepresentable
}

public extension KeyCodeable where Self: NSManagedObject, Key: Hashable, Key.RawValue == String {
    func setProperties(properties: [Key: AnyObject]) {
        let dictionary = properties.reduce([:]) { (previous, next) -> [String: AnyObject] in
            var previous = previous
            previous[next.0.rawValue] = next.1
            return previous
        }
        setValuesForKeysWithDictionary(dictionary)
    }
    
    func update(properties: [Key: AnyObject]) {
        setProperties(properties)
    }
    
    func getProperties(properties: [Key]) -> [String: AnyObject] {
        return dictionaryWithValuesForKeys(properties.map { $0.rawValue })
    }
    
    func get(properties: [Key]) -> [String: AnyObject] {
        return getProperties(properties)
    }
}

public extension KeyCodeable where Self: NSManagedObject, Key: Hashable, Key.RawValue == String {
    static func create(properties: [Key: AnyObject]) -> Self {
        return NSManagedObjectContext.defaultContext().create(self, properties: properties)
    }
    
    static func bulkCreate(properties: [Key: AnyObject]...) -> [Self] {
        return properties.map { NSManagedObjectContext.defaultContext().create(self, properties: $0) }
    }
}