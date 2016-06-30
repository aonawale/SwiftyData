//
//  NSManagedObjectContext.swift
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

public extension NSManagedObjectContext {
    /// This method returns the default NSManagedObjectContext used.
    /// - Returns: The default NSManagedObjectContext used.
    public static func defaultContext() -> NSManagedObjectContext {
        return SwiftData.sharedInstance.managedObjectContext
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
        object.setProperties(properties)
        return object
    }
}

/*
 Extension methods for creating finding NSManagedObject.
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
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        return fetchEntities(T.self, fetchRequest: fetchRequest)
    }
    
    private func objectWithID<T: NSManagedObject where T: ManagedObjectType>(id: NSManagedObjectID) -> T? {
        let object = objectWithID(id)
        if object.fault {
            return object as? T
        }
        let fetchRequest = NSFetchRequest(entityName: T.entityName)
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", object)
        return fetchEntities(T.self, fetchRequest: fetchRequest).first
    }
    
    /// Method to find and return an object of type entity associated
    /// with the provided NSURL paramater.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Parameter id: A NSURL. The object NSManagedObjectID property.
    /// - Returns: An object of type entity or nil if no object with that NSURL exist.
    public func findByNSURL<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type, url: NSURL) -> T? {
        guard let managedObjectID = persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) else { return nil }
        return objectWithID(managedObjectID)
    }
    
    /// Method to find and return an object of type entity associated
    /// with the provided NSManagedObjectID paramater.
    /// - Parameter entity: The type of object to create. // e.g: NSManagedObject.self
    /// - Parameter id: The object NSManagedObjectID property.
    /// - Returns: An object of type entity or nil if no object with that NSManagedObjectID exist.
    public func findById<T: NSManagedObject where T: ManagedObjectType>(entity: T.Type, id: NSManagedObjectID) -> T? {
        return objectWithID(id)
    }
}

/*
 Extension methods for querying NSManagedObject.
 */
public extension NSManagedObjectContext {
    /// This method finds and return all objects of type entity
    /// matching the specified dictionary Key and Value.
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
    ///   - where: A dictionary specifying they keys and value to find.
    /// - Returns: An array of objects of type entity.
    public func find<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable>
        (entity: T.Type, where: [T.Key: AnyObject]) -> [T] {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.predicate = predicateFor(entity, condition: `where`)
        return fetchEntities(entity, fetchRequest: fetchRequest)
    }
    
    /// This method finds and return all objects of type entity
    /// matching the specified format string.
    /// - Parameters:
    ///   - entity: The type of object to find. // e.g: NSManagedObject.self
    ///   - where: The format string for the new predicate.
    ///   - argList: The arguments to substitute into predicate format Values are
    ///     substituted into where format string in the order they appear in the argument list.
    /// - Returns: An array of objects of type entity.
    public func find<T: NSManagedObject where T: ManagedObjectType>
        (entity: T.Type, where: AnyObject, _ argList: AnyObject...) -> [T] {
        let args = argList.first as? [AnyObject] ?? argList
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.predicate = predicateFor(entity, condition: `where`, args: args)
        return fetchEntities(entity, fetchRequest: fetchRequest)
    }
    
    private func predicateFor<T>(entity: T.Type, condition: AnyObject, args: [AnyObject]) -> NSPredicate {
        switch condition {
        case let condition as NSPredicate:
            return condition
        case let condition as String:
            return NSPredicate(format: condition, argumentArray: args)
        default:
            return NSPredicate()
        }
    }
    
    private func predicateFor<T where T: KeyCodeable, T.Key: Hashable>
        (entity: T.Type, condition: [T.Key: AnyObject]) -> NSPredicate {
        return entity.predicateFromDictionary(condition)
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