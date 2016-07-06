//
//  ManagedObjectType.swift
//  SwiftyData
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
    /// - Returns: An array of objects of type Self.
    static func findAll() -> [Self] {
        return NSManagedObjectContext.defaultContext().findAll(Self)
    }
    
    /// Method to find and return an object of type Self associated
    /// with the provided NSManagedObjectID paramater.
    /// - Parameter id: The object NSManagedObjectID property.
    /// - Returns: An object of type `Self` or `nil` if no object with that NSManagedObjectID exist
    static func findById(id: NSManagedObjectID) -> Self? {
        return NSManagedObjectContext.defaultContext().findById(self, id: id)
    }
    
    /// Method to find and return an object of type Self with the object's
    /// NSManagedObjectID URIRepresentation property
    /// - Parameter id: A `NSURL`. The object `NSManagedObjectID.URIRepresentation()` property.
    /// - Returns: An object of type `Self` or `nil` if no object with that NSURL exist.
    static func findByNSURL(url: NSURL) -> Self? {
        return NSManagedObjectContext.defaultContext().findByNSURL(self, url: url)
    }
}

/*
 Extension methods for finding one NSManagedObject.
 */
extension ManagedObjectType where Self: NSManagedObject {
    /// This method finds and return the first found object of type `Self`
    /// matching the specified format string.
    /// This method applies `fetchLimit = 1` to the NSFetchRequest used.
    /// - Parameters:
    ///   - where: The format string for the new predicate.
    ///   - arguments: The arguments to substitute into predicate format Values are
    ///     substituted into where format string in the order they appear in the argument list.
    /// - Returns: An optional object of type `Self`.
    static func findOne(where where: AnyObject, arguments: AnyObject...) -> Self? {
        return NSManagedObjectContext.defaultContext().findOne(self, where: `where`, arguments: arguments)
    }
}

public extension ManagedObjectType where Self: NSManagedObject, Self: KeyCodeable, Self.Key: Hashable, Self.Key.RawValue == String {
    /// This method finds and return the first found object of type `Self`
    /// matching the specified dictionary Key and Value.
    /// This method applies `fetchLimit = 1` to the NSFetchRequest used.
    /// - Parameters:
    ///   - where: A dictionary specifying they keys and value to find.
    /// - Returns: An optional object of type `Self`.
    static func findOne(where where: [Key: AnyObject]) -> Self? {
        return NSManagedObjectContext.defaultContext().findOne(self, where: `where`)
    }
}

/*
 Extension methods for querying NSManagedObject.
 */
public extension ManagedObjectType where Self: NSManagedObject {
    /// This method finds and return all objects of type `Self`
    /// matching the specified format string.
    /// - Parameters:
    ///   - where: The format string for the new predicate.
    ///   - arguments: The arguments to substitute into predicate format. Values are substituted
    ///     into where format string in the order they appear in the argument list.
    ///   - limit: The fetch limit specifies the maximum number of objects that a request
    ///     should return when executed. The default value is 0.
    ///   - skip: This setting allows you to specify an offset at which rows will begin being returned.
    ///     Effectively, the request will skip over the specified number of matching entries.
    ///     **Note: If context is not saved, the fetchOffset property of NSFetchRequest is ignored.**
    ///   - batchSize:  The collection of objects returned when the fetch is executed is broken into batches.
    ///     When the fetch is executed, the entire request is evaluated and the identities of all matching 
    ///     objects recorded, but no more than batchSize objects’ data will be fetched from the persistent 
    ///     store at a time. The array returned from executing the request will be a proxy object that 
    ///     transparently faults batches on demand. The default value is 0. A batch size
    ///     of 0 is treated as infinite, which disables the batch faulting behavior.
    ///   - sort: The sort descriptors specify how the objects returned when the fetch request is issued
    ///     should be ordered—for example by last name then by first name. The sort descriptors are applied
    ///     in the order in which they appear in the sortDescriptors array (serially in lowest-array-index-first order).
    /// - Returns: An array of objects of type `Self`.
    static func find(where where: AnyObject, arguments: AnyObject...,
        limit: Int = 0, skip: Int = 0, batchSize: Int = 0, sort: [NSSortDescriptor] = []) -> [Self] {
        return NSManagedObjectContext.defaultContext()
            .find(self, where: `where`, arguments: arguments, limit: limit, skip: skip, batchSize: batchSize, sort: sort)
    }
}

public extension ManagedObjectType where Self: NSManagedObject, Self: KeyCodeable, Self.Key: Hashable, Self.Key.RawValue == String {
    /// This method finds and return all objects of type Self
    /// matching the specified dictionary Key and Value.
    /// - Parameters:
    ///   - where: A dictionary specifying they keys and value to find.
    ///   - limit: The fetch limit specifies the maximum number of objects that a request
    ///     should return when executed. The default value is 0.
    ///   - skip: This setting allows you to specify an offset at which rows will begin being returned.
    ///     Effectively, the request will skip over the specified number of matching entries.
    ///     **Note: If context is not saved, the fetchOffset property of NSFetchRequest is ignored.**
    ///   - batchSize:  The collection of objects returned when the fetch is executed is broken into batches.
    ///     When the fetch is executed, the entire request is evaluated and the identities of all matching
    ///     objects recorded, but no more than batchSize objects’ data will be fetched from the persistent
    ///     store at a time. The array returned from executing the request will be a proxy object that
    ///     transparently faults batches on demand. The default value is 0. A batch size
    ///     of 0 is treated as infinite, which disables the batch faulting behavior.
    ///   - sort: The sort descriptors specify how the objects returned when the fetch request is issued
    ///     should be ordered—for example by last name then by first name. The sort descriptors are applied
    ///     in the order in which they appear in the sortDescriptors array (serially in lowest-array-index-first order).
    /// - Returns: An array of objects of type Self.
    static func find(where where: [Key: AnyObject], limit: Int = 0, skip: Int = 0, batchSize: Int = 0, sort: [Key: Sort] = [:]) -> [Self] {
        return NSManagedObjectContext.defaultContext().find(self, where: `where`, limit: limit, skip: skip, batchSize: batchSize, sort: sort)
    }
}

/*
 Extension methods for updating NSManagedObject.
 */
public extension ManagedObjectType where Self: NSManagedObject, Self: KeyCodeable, Self.Key: Hashable, Self.Key.RawValue == String {
    /// This method performs batch updates on NSManagedObject
    /// - Parameters:
    ///   - where: A dictionary specifying they keys and value to find.
    ///   - with: A dictionary specifying the keys and values of properties of objects to update.
    ///   - resultType: The type of result to return after the update is done. 
    ///     The default value is `StatusOnlyResultType`
    /// - Returns: The returned value is of type `AnyObject` that can be downcast to the specified `resultType` parameter.
    static func update(where where: [Key: AnyObject], with: [Key: AnyObject],
                             resultType: NSBatchUpdateRequestResultType = .StatusOnlyResultType) -> AnyObject? {
        return NSManagedObjectContext.defaultContext().update(self, where: `where`, with: with, resultType: resultType)
    }
    
    /// This method performs batch updates on NSManagedObject
    /// - Parameters:
    ///   - where: A format string for the new predicate.
    ///   - arguments: The arguments to substitute into predicate format. Values are substituted
    ///     into where format string in the order they appear in the argument list.
    ///   - with: A dictionary specifying the keys and values of properties of objects to update.
    ///   - resultType: The type of result to return after the update is done.
    ///     The default value is `StatusOnlyResultType`
    /// - Returns: The returned value is of type `AnyObject` that can be downcast to the specified `resultType` parameter.
    static func update(where where: AnyObject?, arguments: AnyObject..., with: [Key: AnyObject],
                             resultType: NSBatchUpdateRequestResultType = .StatusOnlyResultType) -> AnyObject? {
        return NSManagedObjectContext.defaultContext().update(self, where: `where`, arguments: arguments, with: with, resultType: resultType)
    }
}

/*
 Extension methods for counting NSManagedObject.
 */
public extension ManagedObjectType where Self: NSManagedObject, Self: KeyCodeable, Self.Key: Hashable {
    /// Returns the number of objects that matches the count criteria.
    /// - Parameter where: A dictionary specifying they keys and value to count.
    /// - Returns: The number of objects that matched the where parameter.
    static func count(where where: [Key: AnyObject]) -> Int {
        return NSManagedObjectContext.defaultContext().count(self, where: `where`)
    }
}

public extension ManagedObjectType where Self: NSManagedObject {
    /// Returns the number of objects that matches the count criteria.
    /// - Parameter where: The format string for the new predicate.
    /// - Parameter arguments: The arguments to substitute into predicate format. Values are substituted
    ///     into where format string in the order they appear in the argument list.
    /// - Returns: The number of objects that matched the where parameter.
    static func count(where where: AnyObject? = nil, arguments: AnyObject...) -> Int {
        return NSManagedObjectContext.defaultContext().count(self, where: `where`, arguments: arguments)
    }
}

/*
 Extension methods for upserting NSManagedObject.
 */
public extension ManagedObjectType where Self: NSManagedObject, Self: KeyCodeable, Self.Key: Hashable, Self.Key.RawValue == String {
    /// Method to create a new instance of object type `Self` 
    /// if an object with provided properties doesn't exist already.
    /// - Parameter properties: A dictionary of type [Key: AnyObject].
    /// - Returns: An object of type Self.
    static func upsert(properties: [Key: AnyObject]) -> Self {
        return NSManagedObjectContext.defaultContext().upsert(self, properties: properties)
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