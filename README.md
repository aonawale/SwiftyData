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
- [Find](#find)
- [FindOne](#findOne)
- [Queries](#queries)
- [Sorting](#sorting)
- [Limiting](#limiting)
- [Pagination or Offsetting](#pagination-or-offsetting)
- [Batching](#batching)

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
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyData.swift'
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

1. Import SwiftyData at the of the files using SwiftyData.

```swift
import SwiftyData

class Person: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var age: Int64
}
```

2. Optionally you can adopt and conform to `KeyCodeable` protocol so you can represent your properties using enums and be sure of type safety.

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

### Get and set properties

```swift
// Returns a dictionary of `[String: AnyObject]`
person.get([.name, .age])

// Set properties to new value
person.set([.name: "Bar", .age: 20])
```

### Delete

```swift
// Deletes person
person.destroy()

// Deletes all `Person`
Person.destroyAll()
```

### Save

```swift
// Saves person to persistence store
// Returns True if the save is successful or False if otherwise

person.save()

// Also returns false if there are no changes to save.
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

### Find

```swift
// Find all `Person`
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
// Finds one `Person` whose name is `Foo`
Person.findOne(where: [.name: "Foo"])

// You can a `NSPredicate` format string and arguments
// Finds one `Person` whose age is less than 20
Person.findOne(where: "age < %@", arguments: 20)

// Or you can just drop in a `NSPredicate`
// Finds one `Person` whose age is greater than 18
let predicate = NSPredicate(format: "age > 18")
Person.findOne(where: predicate)
```

### Queries

```swift
// Finds all `Person` less than 30 years old
let lessThan30 = Person.find(where: "age < %@", arguments: 30)

// Finds `Person` named `Foo` that has age `18`
let foo = Person.find(where: "name == %@ AND age == %@", arguments: "Foo", 18)

// Finds `Person` named `Bor` that has age `20` 
let bar = Person.find(where: [.name: "Bar", .age: 20])

// Finds all `Person` greater than 18 years old 
let predicate = NSPredicate(format: "age > 18")
let greaterThan18 = Person.find(where: predicate)
```

### Sorting

```swift
// Finds all `Person` and sort sort by name: ascending
Person.find(where: [:], sort: [.name: .ASC])

// You can pass in an array of `NSSortDescriptor`
// Finds all `Person` and sort sort by name and age
let byName = NSSortDescriptor(key: "name", ascending: false)
let byAge = NSSortDescriptor(key: "age", ascending: true)
let sorted = Person.find(where: "age > %@", arguments: 10, "ME", sort: [byName, byAge])
```

### Limiting

```swift
// Returns just two `Person`
let justTwo = Person.find(where: "age > %@", arguments: 10, limit: 2)
```

### Pagination or Offsetting

```swift
Person.bulkCreate([.name: "Ayo", .age: 19], [.name: "Ahmed", .age: 29], [.name: "Onawale", .age: 32])

Person.save() // If context is not saved, the fetchOffset property of NSFetchRequest is ignored.

// Returns an array of `Person` object skipping the first two result
let skipTwo = Person.find(where: "age > %@", arguments: 10, skip: 2)
```

### Batching

```swift
// Returns a proxy object array of `Person` that transparently faults batches on demand.
Person.find(where: "age > %@", arguments: 10, batchSize: 2)
```

## Roadmap

- Aggregation
- Batch update
- Custom Core Data
- Upserting

## Requirements

iOS 8 or later.

## License

SwiftyData is available under the MIT license. See the LICENSE.md file for more information.
