//
//  CoreDataObserver.swift
//
//
//  Created by AbdelAli on 24/1/2022.
//

import Foundation
import CoreData

public struct ObjectsDidChangeNotification {

    fileprivate let notification: Notification

    init(notification: Notification) {
        assert(notification.name == .NSManagedObjectContextObjectsDidChange)
        self.notification = notification
    }

    public var insertedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInsertedObjectsKey)
    }

    public var updatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSUpdatedObjectsKey)
    }

    public var deletedObjects: Set<NSManagedObject> {
        return objects(forKey: NSDeletedObjectsKey)
    }

    public var refreshedObjects: Set<NSManagedObject> {
        return objects(forKey: NSRefreshedObjectsKey)
    }

    public var invalidatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInvalidatedObjectsKey)
    }

    public var invalidatedAllObjects: Bool {
        return (notification as Notification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let moc = notification.object as? NSManagedObjectContext
        else { fatalError("Invalid notification object") }
        return moc
    }

    fileprivate func objects(forKey key: String) -> Set<NSManagedObject> {
        return (notification.userInfo?[key] as? Set<NSManagedObject>) ?? Set()
    }
}

private extension NSManagedObjectContext {

    func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { n in
            let wrappedNote = ObjectsDidChangeNotification(notification: n)
            handler(wrappedNote)
        }
    }
}

final public class ManagedObjectObserver {

    enum ChangeType {
        case delete
        case update
    }

    fileprivate var token: NSObjectProtocol!

    init?(object: NSManagedObject, changeHandler: @escaping (ChangeType, ObjectsDidChangeNotification) -> ()) {
        guard let moc = object.managedObjectContext else { return nil }
        token = moc.addObjectsDidChangeNotificationObserver { [weak self] notification in
            guard let changeType = self?.changeType(of: object, in: notification) else { return }
            changeHandler(changeType, notification)
        }
    }

    deinit {
        if let t = token {
            NotificationCenter.default.removeObserver(t)
        }
    }

    fileprivate func changeType(
        of object: NSManagedObject,
        in notification: ObjectsDidChangeNotification
    ) -> ChangeType? {
        let deleted = notification.deletedObjects.union(notification.invalidatedObjects)
        if notification.invalidatedAllObjects || deleted.contains(object) {
            return .delete
        }
        let updated = notification.updatedObjects.union(notification.refreshedObjects)
        if updated.contains(object) {
            return .update
        }
        return nil
    }
}
