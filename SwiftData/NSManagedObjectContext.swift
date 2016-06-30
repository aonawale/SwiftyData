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
    public static func defaultContext() -> NSManagedObjectContext {
        return SwiftData.sharedInstance.managedObjectContext
    }
}

public extension NSManagedObjectContext {
    public func create<T: NSManagedObject where T: ManagedObjectType>(record: T.Type) -> T {
        guard let object = NSEntityDescription.insertNewObjectForEntityForName(record.entityName, inManagedObjectContext: self) as? T else {
            fatalError("Entity \(record.entityName) does not correspond to \(record.self)")
        }
        return object
    }
    
    public func create<T: NSManagedObject where T: ManagedObjectType, T: KeyCodeable, T.Key.RawValue == String>(record: T.Type, properties: [T.Key: AnyObject]) -> T {
        let object = create(T)
        object.setProperties(properties)
        return object
    }
    
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
    
    public func findAll<T: NSManagedObject where T: ManagedObjectType>(record: T.Type) -> [T] {
        let fetchRequest = NSFetchRequest(entityName: record.entityName)
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
    
    public func findByNSURL<T: NSManagedObject where T: ManagedObjectType>(record: T.Type, url: NSURL) -> T? {
        guard let managedObjectID = persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) else { return nil }
        return objectWithID(managedObjectID)
    }
    
    public func findById<T: NSManagedObject where T: ManagedObjectType>(record: T.Type, id: NSManagedObjectID) -> T? {
        return objectWithID(id)
    }
    
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