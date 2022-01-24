# ManagedObjectObserver

`ManagedObjectObserver` class registers for the objects-did-change notification (.NSManagedObjectContextObjectsDidChange). 
Whenever the notification is sent, it traverses the user info of the notification to check whether or not a deletion of the observed object has occurred

```swift
let observer = ManagedObjectObserver(object: mood) { [weak self] type in
    guard type == .delete else { return }
    //...
}
```

# Installation

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/abdalaliii/ManagedObjectObserver.git")
]
```

# License

**ManagedObjectObserver** is available under the MIT license.
