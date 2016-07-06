//
//  NSManagedObjectContext.swift
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

public enum Sort {
    case ASC
    case DESC
    
    var value: Bool {
        switch self {
        case .ASC:
            return true
        case .DESC:
            return false
        }
    }
}

public extension NSManagedObjectContext {
    /// This method returns the default NSManagedObjectContext used.
    /// - Returns: The default NSManagedObjectContext used.
    public static func defaultContext() -> NSManagedObjectContext {
        return SwiftyData.sharedInstance.managedObjectContext
    }
}

/*
 Extension methods for creating NSManagedObject.
*/
public extension NSManagedObjectContext {
    /// This method to create a new instance of NSManagedObject.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Returns: A new instance of object type entity.
    public func create<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type) -> T {
        guard let object = NSEntityDescription.insertNewObjectForEntityForName(entity.entityName, inManagedObjectContext: self) as? T else {
            fatalError("Entity \(entity.entityName) does not correspond to \(entity.self)")
        }
        return object
    }
    
    /// Creates a new instance of NSManagedObject with default properties values.
    /// - Parameters:
    ///   - entity: The type of object to create. // e.g: NSManagedObject.self
    ///   - properties: A dictionary of type [Key: AnyObject], where Key is RawRepresentable.
    /// - Returns: A new instance of object type entity.
    public func create<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>(entity: T.Type, properties: [T.Key: AnyObject]) -> T {
        let object = create(T)
        object.set(properties)
        return object
    }
}

/*
 Extension methods for upserting NSManagedObject.
 */
public extension NSManagedObjectContext {
    /// Method to create a new instance of object type `Self`
    /// if an object with provided properties doesn't exist already.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Returns: An object of type Self.
    public func upsert<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>
        (entity: T.Type, properties: [T.Key: AnyObject]) -> T {
        guard let object = findOne(entity, where: properties) else {
            return create(entity, properties: properties)
        }
        return object
    }
}

/*
 Extension methods for finding NSManagedObject.
*/
public extension NSManagedObjectContext {
    private func fetchEntities<T: NSManagedObject where T: ManagedObjectType>(type: T.Type, fetchRequest: NSFetchRequest) -> [T] {
        do {
            guard let entities = try executeFetchRequest(fetchRequest) as? [T] else {
                fatalError("Unable to Cast result type to specified type \(type.self)")
            }
            return entities
        } catch {
            print("Error occured while fetching records: ", error)
            return [T]()
        }
    }
    
    /// This method fetches all objects of type entity from the persistent stores into the context.
    /// The context will match the results from persistent stores with current changes
    /// in the context (so inserted objects are returned even if they are not persisted yet).
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Returns: An array of objects of type entity
    public func findAll<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type) -> [T] {
        return find(entity, where: nil)
    }
    
    private func objectWithID<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type, id: NSManagedObjectID) -> T? {
        let object = objectWithID(id)
        if object.fault {
            return object as? T
        }
        return findOne(entity, where: NSPredicate(format: "SELF == %@", object))
    }
    
    /// Method to find and return an object of type entity associated
    /// with the provided NSURL paramater.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Parameter id: A NSURL. The object NSManagedObjectID property.
    /// - Returns: An object of type entity or nil if no object with that NSURL exist.
    public func findByNSURL<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type, url: NSURL) -> T? {
        guard let managedObjectID = persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) else { return nil }
        return objectWithID(entity, id: managedObjectID)
    }
    
    /// Method to find and return an object of type entity associated
    /// with the provided NSManagedObjectID paramater.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Parameter id: The object NSManagedObjectID property.
    /// - Returns: An object of type entity or nil if no object with that NSManagedObjectID exist.
    public func findById<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type, id: NSManagedObjectID) -> T? {
        return objectWithID(entity, id: id)
    }
}

/*
 Extension methods for updating NSManagedObject.
 */
public extension NSManagedObjectContext {
    /// This method performs batch updates on NSManagedObject
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
    ///   - where: A dictionary specifying they keys and value to find.
    ///   - with: A dictionary specifying the keys and values of properties of objects to update.
    ///   - resultType: The type of result to return after the update is done.
    ///     The default value is `StatusOnlyResultType`
    /// - Returns: The returned value is of type `AnyObject` that can be downcast to the specified `resultType` parameter.
    public func update<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>
        (entity: T.Type, where: [T.Key: AnyObject], with: [T.Key: AnyObject],
         resultType: NSBatchUpdateRequestResultType = .StatusOnlyResultType) -> AnyObject? {
        let predicate = predicateFor(entity, condition: `where`)
        return update(entity, where: predicate, with: with, resultType: resultType)
    }
    
    /// This method performs batch updates on NSManagedObject
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
    ///   - where: A format string for the new predicate.
    ///   - arguments: The arguments to substitute into predicate format. Values are substituted
    ///     into where format string in the order they appear in the argument list.
    ///   - with: A dictionary specifying the keys and values of properties of objects to update.
    ///   - resultType: The type of result to return after the update is done.
    ///     The default value is `StatusOnlyResultType`
    /// - Returns: The returned value is of type `AnyObject` that can be downcast to the specified `resultType` parameter.
    public func update<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>
        (entity: T.Type, where: AnyObject?, arguments: AnyObject..., with: [T.Key: AnyObject],
         resultType: NSBatchUpdateRequestResultType = .StatusOnlyResultType) -> AnyObject? {
        let args = arguments.first as? [AnyObject] ?? arguments
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entity.entityName)
        batchUpdateRequest.predicate = predicateFor(entity, condition: `where`, args: args)
        batchUpdateRequest.propertiesToUpdate = entity.rawKeysFromDictionary(with)
        batchUpdateRequest.resultType = resultType
        do {
            return (try executeRequest(batchUpdateRequest) as! NSBatchUpdateResult).result
        } catch {
            print("NSBatchUpdateRequest error: \(error)")
            rollback()
        }
        return nil
    }
}

/*
 Extension methods for finding one NSManagedObject.
 */
public extension NSManagedObjectContext {
    /// This method finds and return the first found object of type Self
    /// matching the specified format string.
    /// This method applies LIMIT 1 to the NSFetchRequest used.
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
    ///   - where: The format string for the new predicate.
    /// - Returns: An optional object of type Self.
    public func findOne<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>
        (entity: T.Type, where: [T.Key: AnyObject]) -> T? {
        return find(entity, where: `where`, limit: 1).first
    }
    
    /// This method finds and return all objects of type entity
    /// matching the specified format string.
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
    ///   - where: The format string for the new predicate.
    ///   - arguments: The arguments to substitute into predicate format Values are
    ///     substituted into where format string in the order they appear in the argument list.
    /// - Returns: An array of objects of type entity.
    public func findOne<T: NSManagedObject where T: ManagedObjectType>
        (entity: T.Type, where: AnyObject, arguments: AnyObject...) -> T? {
        let args = arguments.first as? [AnyObject] ?? arguments
        return find(entity, where: `where`, arguments: args, limit: 1).first
    }
}

/*
 Extension methods for counting NSManagedObject.
 */
public extension NSManagedObjectContext {
    /// Returns the number of objects that matches the count criteria.
    /// - Parameter entity: The type of object to find. // e.g: NSManagedObject.self
    /// - Parameter where: A dictionary specifying they keys and value to count.
    /// - Returns: The number of objects that matched the where parameter.
    public func count<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable>
        (entity: T.Type, where: [T.Key: AnyObject]) -> Int {
        return count(entity, where: predicateFor(entity, condition: `where`))
    }
    
    /// Returns the number of objects that matches the count criteria.
    /// - Parameter entity: The type of object to find. // e.g: NSManagedObject.self
    /// - Parameter where: The format string for the new predicate.
    /// - Parameter arguments: The arguments to substitute into predicate format. Values are substituted
    ///     into where format string in the order they appear in the argument list.
    /// - Returns: The number of objects that matched the where parameter.
    public func count<T: NSManagedObject where T: ManagedObjectType>
        (entity: T.Type, where: AnyObject? = nil, arguments: AnyObject...) -> Int {
        let args = arguments.first as? [AnyObject] ?? arguments
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.predicate = predicateFor(entity, condition: `where`, args: args)
        return countForFetchRequest(fetchRequest, error: nil)
    }
}

/*
 Extension methods for querying NSManagedObject.
 */
public extension NSManagedObjectContext {
    /// This method finds and return all objects of type Self
    /// matching the specified dictionary Key and Value.
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
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
    public func find<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>
        (entity: T.Type, where: [T.Key: AnyObject], limit: Int = 0, skip: Int = 0, batchSize: Int = 0, sort: [T.Key: Sort]? = nil) -> [T] {
        let sortDescriptors = sort == nil ? nil : sortDescriptorFor(entity, sort: sort!)
        let predicate = predicateFor(entity, condition: `where`)
        return find(entity, where: predicate, limit: limit, skip: skip, batchSize: batchSize, sort: sortDescriptors)
    }
    
    /// This method finds and return all objects of type Self
    /// matching the specified format string.
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
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
    /// - Returns: An array of objects of type Self.
    public func find<T: NSManagedObject where T: ManagedObjectType>
        (entity: T.Type, where: AnyObject?, arguments: AnyObject..., limit: Int = 0, skip: Int = 0, batchSize: Int = 0, sort: [NSSortDescriptor]? = nil) -> [T] {
        let args = arguments.first as? [AnyObject] ?? arguments
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = skip
        fetchRequest.fetchBatchSize = batchSize
        fetchRequest.sortDescriptors = sort
        fetchRequest.predicate = predicateFor(entity, condition: `where`, args: args)
        return fetchEntities(entity, fetchRequest: fetchRequest)
    }
    
    private func predicateFor<T>(entity: T.Type, condition: AnyObject?, args: [AnyObject]) -> NSPredicate? {
        switch condition {
        case let condition as NSPredicate:
            return condition
        case let condition as String:
            return NSPredicate(format: condition, argumentArray: args)
        default:
            return nil
        }
    }
    
    private func predicateFor<T where T: KeyCodeable, T.Key: Hashable>
        (entity: T.Type, condition: [T.Key: AnyObject]) -> NSPredicate? {
        return condition.isEmpty ? nil : entity.predicateFromDictionary(condition)
    }
    
    private func sortDescriptorFor<T where T: KeyCodeable, T.Key: Hashable, T.Key.RawValue == String>
        (entity: T.Type, sort: [T.Key: Sort]) -> [NSSortDescriptor]? {
        return sort.isEmpty ? nil : entity.sortDiscriptorsFromDictionary(sort)
    }
}

/*
 Extension methods for deleting NSManagedObject.
*/
public extension NSManagedObjectContext {
    /// This method deletes all instances of type entity from the context.
    /// Note - You'll need to ultimately save the context so that the deletion
    /// can be persisted to the underlaying peristent store.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    public func destroyAll<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type) {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.includesPropertyValues = false
        // For iOS 9.0 and later
        if #available(iOS 9.0, *) {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try executeRequest(batchDeleteRequest)
                reset()
            } catch {
                print("NSBatchDeleteRequest error: \(error)")
                rollback()
            }
        } else {
            // Fallback on earlier versions
            fetchEntities(entity, fetchRequest: fetchRequest).forEach { deleteObject($0) }
        }
    }
}