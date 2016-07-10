//
//  SwiftyData.swift
//  SwiftyData
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

public enum LogLevel {
    case None, Info, Debug
}

public class SwiftyData {
    
    private init() {}
    
    public static let sharedData = SwiftyData()
    
    public var logLevel = LogLevel.Debug
    
    private var _bundle: NSBundle?
    
    public var bundle: NSBundle {
        get {
            if let bundle = _bundle {
                return bundle
            }
            return NSBundle.mainBundle()
        }
        set {
            _bundle = newValue
        }
    }
    
    private var appName: String {
        return bundle.infoDictionary?["CFBundleName"] as? String ?? "SwiftyData"
    }
    
    private var _managedObjectContext: NSManagedObjectContext?
    
    public var managedObjectContext: NSManagedObjectContext {
        get {
            if let context = _managedObjectContext {
                return context
            }
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
            _managedObjectContext = context
            log("Instantiating the managedObjectContext property ", context)
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
        let coordinator = persistentStoreCoordinator(type: NSSQLiteStoreType, storeURL: sqliteStoreURL)
        log("Instantiating the persistentStoreCoordinator property ", coordinator)
        _persistentStoreCoordinator = coordinator
        return coordinator
    }
    
    private func persistentStoreCoordinator(type storeType: String, storeURL: NSURL?) -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            let storeOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: storeOptions)
        } catch {
            log("Error adding a persistence store with type: \(storeType) to persistentStoreCoordinator ", error)
        }
        return coordinator
    }
    
    private var _managedObjectModel: NSManagedObjectModel?
    
    public var managedObjectModel: NSManagedObjectModel {
        if let mom = _managedObjectModel {
            return mom
        }
        if let resource = modelName, modelURL = bundle.URLForResource(resource, withExtension: "momd") {
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        } else {
            _managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([bundle])
        }
        log("Instantiating the managedObjectModel property ", _managedObjectModel)
        return _managedObjectModel!
    }
    
    public var modelName: String? {
        didSet {
            _managedObjectContext = nil
            _persistentStoreCoordinator = nil
        }
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        debugPrint("Instantiating the applicationDocumentsDirectory property ", documentsDirectory)
        return documentsDirectory
    }()
    
    private var sqliteStoreURL: NSURL {
        let url = applicationDocumentsDirectory.URLByAppendingPathComponent(databaseName)
        log("Instantiating the sqliteStoreURL property ", url)
        return url
    }
    
    private var _databaseName: String?
    
    public var databaseName: String {
        get {
            if let db = _databaseName {
                return db
            }
            log("Instantiating the databaseName property ", "\(appName).sqlite")
            return "\(appName).sqlite"
        }
        set {
            _databaseName = "\(newValue).sqlite"
            _managedObjectContext = nil
            _persistentStoreCoordinator = nil
        }
    }
    
    private func log(message: String, _ items: Any...) {
        switch logLevel {
        case .Info:
            print(message)
        case .Debug:
            debugPrint(message, items)
        default:
            return
        }
    }
    
}