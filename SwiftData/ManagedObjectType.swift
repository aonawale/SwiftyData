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