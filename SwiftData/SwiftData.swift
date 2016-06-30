//
//  SwiftData.swift
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

public class SwiftData {
    
    private init() {}
    
    public static let sharedInstance = SwiftData()
    
    private var bundle: NSBundle {
        if let _ = NSClassFromString("XCTest") {
            return NSBundle(identifier: "com.ahmedonawale.SwiftDataTests")!
        }
        return NSBundle.mainBundle()
    }
    
    private var _appName: String?
    
    public var appName: String {
        get {
            if let name = _appName {
                return name
            }
            return bundle.infoDictionary!["CFBundleName"] as! String
        }
        set {
            _appName = newValue
        }
    }
    
    private var _managedObjectContext: NSManagedObjectContext?
    
    public var managedObjectContext: NSManagedObjectContext {
        get {
            if let context = _managedObjectContext {
                return context
            }
            print("Instantiating the managedObjectContext property")
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
            _managedObjectContext = context
            return context
        }
        set {
            _managedObjectContext = newValue
        }
    }
    
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if let store = _persistentStoreCoordinator {
            return store
        }
        print("Instantiating the persistentStoreCoordinator property")
        let coordinator = persistentStoreCoordinatorType(NSSQLiteStoreType, storeURL: sqliteStoreURL)
        _persistentStoreCoordinator = coordinator
        return coordinator
    }
    
    private func persistentStoreCoordinatorType(storeType: String, storeURL: NSURL?) -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            let storeOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: storeOptions)
        } catch {
            print("Error adding a persistence store with type: \(storeType) to persistentStoreCoordinator: ", error)
        }
        return coordinator
    }
    
    private var _managedObjectModel: NSManagedObjectModel?
    
    public var managedObjectModel: NSManagedObjectModel {
        get {
            if let mom = _managedObjectModel {
                return mom
            }
            print("Instantiating the managedObjectModel property")
            let modelURL = bundle.URLForResource(modelName, withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
            return _managedObjectModel!
        }
    }
    
    private var _modelName: String?
    
    public var modelName: String {
        get {
            if let model = _modelName {
                return model
            }
            print("Instantiating the modelName property")
            return appName
        }
        set {
            _modelName = newValue
            _managedObjectContext = nil
            _persistentStoreCoordinator = nil
        }
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        print("Instantiating the applicationDocumentsDirectory property")
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last!
    }()
    
    private var sqliteStoreURL: NSURL {
        print("Instantiating the sqliteStoreURL property")
        return applicationDocumentsDirectory.URLByAppendingPathComponent(databaseName)
    }
    
    private var _databaseName: String?
    
    public var databaseName: String {
        get {
            if let db = _databaseName {
                return db
            }
            print("Instantiating the databaseName property")
            return "\(appName).sqlite"
        }
        set {
            _databaseName = newValue
            _managedObjectContext = nil
            _persistentStoreCoordinator = nil
        }
    }
    
}