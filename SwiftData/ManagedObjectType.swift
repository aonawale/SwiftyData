//
//  ManagedObjectType.swift
//  SwiftData
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

import CoreData

/// A type that can be represented as a NSManagedObject
/// or a NSManagedObject subclass.
public protocol ManagedObjectType {
    /// A required `static` property representing the name
    /// of a NSManagedObject type. Default implementation
    /// returns a textual representation of Self. All conformer
    /// should provide their own custom implementation and provide
    /// the class name defined in the NSManagedObjectModel.
    static var entityName: String { get }
}

public extension ManagedObjectType where Self: NSManagedObject {
    /// This is the default implementation of `entityName`
    /// requirement. Be advised to provide a custom implementation
    /// that returns the class name defined in the NSManagedObjectModel.
    public static var entityName: String {
        return String(self)
    }
}

/*
 Extension methods for finding NSManagedObject
 */
public extension ManagedObjectType where Self: NSManagedObject {
    /// This method fetches all objects of type Self from the persistent stores into the context.
    /// The default context will match the results from persistent stores with current changes 
    /// in the context (so inserted objects are returned even if they are not persisted yet).
    /// - Returns: An array of objects of type Self
    static func findAll() -> [Self] {
        return NSManagedObjectContext.defaultContext().findAll(Self)
    }
    
    /// Method to find and return an object of type Self associated
    /// with the provided NSManagedObjectID paramater.
    /// - Parameter id: The object NSManagedObjectID property.
    /// - Returns: An object of type Self or nil if no object with that NSManagedObjectID exist
    static func findById(id: NSManagedObjectID) -> Self? {
        return NSManagedObjectContext.defaultContext().findById(self, id: id)
    }
    
    /// Method to find and return an object of type Self with the object's
    /// NSManagedObjectID URIRepresentation property
    /// - Parameter id: A NSURL. The object NSManagedObjectID.URIRepresentation() property.
    /// - Returns: An object of type Self or nil if no object with that NSURL exist.
    static func findByNSURL(url: NSURL) -> Self? {
        return NSManagedObjectContext.defaultContext().findByNSURL(self, url: url)
    }
}

/*
 Extension methods for creating NSManagedObject
 */
public extension ManagedObjectType where Self: NSManagedObject {
    /// Method to create a new instance of object type Self.
    /// - Returns: A new instance of object type Self.
    public static func create() -> Self {
        return NSManagedObjectContext.defaultContext().create(Self)
    }
}

/*
 Extension methods for saving NSManagedObject.
 */
public extension ManagedObjectType where Self: NSManagedObject {
    /// This method calls save on the default NSManagedObjectContext.
    /// The save is not performed if the default NSManagedObjectContext has no changes
    /// or if the object the method is being called on is detached from it's context.
    /// - Returns: A boolean value TRUE if the save is successful or FALSE if not.
    public func save() -> Bool {
        return Self.saveContext(self.managedObjectContext)
    }
    
    /// This method calls save on the default NSManagedObjectContext.
    /// The save is not performed if the default NSManagedObjectContext has no changes.
    /// - Returns: A boolean value TRUE if the save is successful or FALSE if not.
    public static func save() -> Bool {
        return Self.saveContext(NSManagedObjectContext.defaultContext())
    }
    
    private static func saveContext(context: NSManagedObjectContext?) -> Bool {
        guard let unwrapedContext = context where unwrapedContext.hasChanges else {
            return false
        }
        do {
            try unwrapedContext.save()
        } catch {
            print("Unresolved error: \(error) while saving context for entity \(self)")
            return false
        }
        return true
    }
}

/*
 Extension methods for deleting NSManagedObject.
 */
public extension ManagedObjectType where Self: NSManagedObject {
    /// This method deletes the object the method is being called on from the context.
    /// Note - You'll need to ultimately save the context so that the deletion
    /// can be persisted to the underlaying peristent store.
    public func destroy() {
        self.managedObjectContext?.deleteObject(self)
    }
    
    /// This method deletes all instances of type Self from the context.
    /// Note - You'll need to ultimately save the context so that the deletion
    /// can be persisted to the underlaying peristent store.
    public static func destroyAll() {
        NSManagedObjectContext.defaultContext().destroyAll(self)
    }
}

/*
 Extension methods for reloading NSManagedObject persisted properties values.
 */
public extension ManagedObjectType where Self: NSManagedObject {
    /// This method updates the persistent properties of the object this
    /// method is called on to use the latest values from the persistent store.
    func reload() {
        NSManagedObjectContext.defaultContext().refreshObject(self, mergeChanges: false)
    }
}