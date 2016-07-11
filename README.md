# SwiftyData

> A Swift Core Data wrapper with nice API for interacting with managed objects and managed object contexts.

## Table of content

- [Installation](#installation)
- [Getting started](#getting-started)
- [Create](#create)
- [Get and set properties](#get-and-set-properties)
- [Delete](#delete)
- [Save](#save)
- [Reload](#reload)
- [Upsert](#upsert)
- [Find](#find)
- [FindOne](#findone)
- [Queries](#queries)
- [Sorting](#sorting)
- [Limiting](#limiting)
- [Pagination or Offsetting](#pagination-or-offsetting)
- [Batching](#batching)
- [Aggregation](#aggregation)
- [Batch Update](#batch-update)
- [Custom SwiftyData](#custom-swiftydata)

## Requirements

- iOS 8.0+
- Xcode 7+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate SwiftyData into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyData'
end
```

Then, run the following command:

```bash
$ pod install
```

Then add `import SwiftyData` to the top of the files using SwiftyData.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SwiftyData into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "aonawale/SwiftyData" >= 0.0.1
```

Run `carthage update` to build the framework and drag the built `SwiftyData.framework` into your Xcode project.

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate SwiftyData into your project manually.


## Getting started

Import `SwiftyData` at the top of the files using SwiftyData.

```swift
import SwiftyData

class Person: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var age: Int64
}
```

Optionally, you can adopt and conform to `KeyCodeable` protocol so that you can represent your properties using enums and be sure of type safety.

```swift
extension Person: KeyCodeable {
    enum Key: String {
        case name
        case age
    }
}
```

### Create

```swift
// Create a Person
let person = Person.create() // No casting needed, just create!
person.name = "Foo"
person.age = 18

// Or you can just create with properties:
let person = Person.create([.name: "Foo", .age: 18])

// You can also create multiple instances all at once.
let people = Person.bulkCreate([.name: "Foo", .age: 19],
                                [.name: "Bar", .age: 29],
                                [.name: "Baz", .age: 32])
```

Using NSManagedObjectContext

```swift
let context = NSManagedObjectContext.defaultContext()
context.create(Person)
context.create(Person.self, properties: [.name: "Foo", .age: 18])
```
> All the methods available on NSManagedObject subclasses are also available on NSManagedObject. Difference is that the context takes as it's first argument the class name on which to operate on.

### Get and set properties

```swift
// Returns a dictionary of [String: AnyObject]
person.get([.name, .age])

// Set properties to new value
person.set([.name: "Bar", .age: 20])
```

### Delete

```swift
// Deletes person
person.destroy()

// Deletes all Person
Person.destroyAll()
```

### Save

Saves the object or objects to the persistence store. Returns `True` if the save is successful or `False` if otherwise. Also returns `False` if there are no changes to save in the NSManagedObjectContext.

```swift
// Saves person
let person = Person.create()
person.save() // true
person.save() // false
person.name = "Foo"
person.save() // true

// Same as calling
Person.save()
```

### Reload

```swift
// Reloads person properties from the persistence store
let person = Person.create([.name: "Foo", .age: 18])
person.save()
person.set([.name: "Bar", .age: 20])
person.name // Baz
person.age // 20
person.reload()
person.name // Foo
person.age // 18
```

### Upsert

If there is already an object with the supplied properties, it returns that object, otherwise creates a new one with the supplied properties.
```swift
Person.bulkCreate([.name: "Foo", .age: 19], [.name: "Bar", .age: 29])
Person.count() // returns 2
Person.upsert([.name: "Foo", .age: 19])
Person.count() // returns 2
Person.upsert([.name: "Baz", .age: 32])
Person.count() // returns 3
```

### Find

```swift
// Find all Person
// Returns an array of all person
Person.findAll()

// Find by id
let id = person.objectID
Person.findById(id)

// Find by NSURL
let url = perosn.objectID.URIRepresentation()
Person.findByNSURL(url)
```

### FindOne

```swift
// Finds one Person whose name is Foo
Person.findOne(where: [.name: "Foo"])

// You can a NSPredicate format string and arguments
// Finds one Person whose age is less than 20
Person.findOne(where: "age < %@", arguments: 20)

// Or you can just drop in a NSPredicate
// Finds one Person whose age is greater than 18
let predicate = NSPredicate(format: "age > 18")
Person.findOne(where: predicate)
```

### Queries

```swift
// Finds all Person less than 30 years old
let lessThan30 = Person.find(where: "age < 30")

// Finds Person named Foo that has age 18
let foo = Person.find(where: "name == %@ AND age == %@", arguments: "Foo", 18)

// Finds Person named Bar that has age 20
let bar = Person.find(where: [.name: "Bar", .age: 20])

// Finds all Person greater than 18 years old 
let predicate = NSPredicate(format: "age > 18")
let greaterThan18 = Person.find(where: predicate)
```

### Sorting

```swift
// Finds all Person and sort by name: ascending
Person.find(where: [:], sort: [.name: .ASC])

// You can pass in an array of NSSortDescriptor
// Finds all Person and sort by name and age
let byName = NSSortDescriptor(key: "name", ascending: false)
let byAge = NSSortDescriptor(key: "age", ascending: true)
let sorted = Person.find(where: "age > %@", arguments: 10, "ME", sort: [byName, byAge])
```

### Limiting

```swift
// Finds and return just two Person
let justTwo = Person.find(where: "age > 10", limit: 2)
```

### Pagination or Offsetting

```swift
Person.bulkCreate([.name: "Foo", .age: 19], [.name: "Bar", .age: 29], [.name: "Baz", .age: 32])

Person.save() // If context is not saved, the fetchOffset property of NSFetchRequest is ignored.

// Returns an array of Person object skipping the first two result
let skipTwo = Person.find(where: "age > %@", arguments: 10, skip: 2)
```

> You need to call save on the NSManagedObject subclass otherwise the skip argument will be ignored.


### Batching

```swift
// Returns a proxy object array of Person that transparently faults batches on demand.
Person.find(where: "age > %@", arguments: 10, batchSize: 2)
```

### Aggregation

```swift
// Counts and return the number of Person
Person.count()

// You can supply a query to narrow down the objects to count
Person.count(where: "age < 30")

// You can also do this if you conform to KeyCodeable protocol
Person.count(where: [.name: "Foo"])
```

### Batch Update

Performs a batch update on all managed objects matching the supplied query. The return type is NSBatchUpdateRequestResultType which defaults to StatusOnlyResultType.

```swift
// Updates all Person whose name begins with fo to Foo
Person.update(where: "name BEGINSWITH[cd] %@", arguments: "fo", with: [.name: "Foo"])

// You can specify a result type you prefer. Here we are
// specifying a result type which returns the number of updated objects
let updatedCount = Person.update(where: "age < 30", with: [.age: 30], resultType: .UpdatedObjectsCountResultType) as? Int

// You can supply a NSPredicate if you like.
let age = NSPredicate(format: "age == 30")
let name = NSPredicate(format: "name == %@", "Foo")
let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [age, name])
Person.update(where: predicate, with:[.name: "Bar", .age: 19])
```

> Conformance to KeyCodeable protocol is required for batch updates.

## Custom SwiftyData

By default SwiftyData merges all the Model files with extension `xcdatamodeld` in your project directory. So it doesn't matter what you name your model or if you have multiple model files, they will all be found.

If you dont want this behaviour, you can explicitly set the name of model file you want SwiftyData to use in your AppDelegate and only this file will be used.

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    SwiftyData.sharedData.modelName = "MyModel"
    return true
}
```

You can set a database name if you don't want the default behaviour which uses the application name. You can set this before you return from your AppDelegate's `application didFinishLaunchingWithOptions` method.

```
SwiftyData.sharedData.databaseName = "MyDatabase"
```

You can also set a custom managed object context before returning from `application didFinishLaunchingWithOptions` method if you don't prefer to use the default one.

```
let context = NSManagedObjectContext(concurrencyType: ...)
SwiftyData.sharedData.managedObjectContext = context
```

## Roadmap

- Realm support
- Object Relationships
- JSON support


## License

SwiftyData is available under the MIT license. See the LICENSE.md file for more information.