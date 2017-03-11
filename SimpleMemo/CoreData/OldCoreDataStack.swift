//
//  CoreDataStack.swift
//  EverMemo
//
//  Created by  李俊 on 15/8/5.
//  Copyright (c) 2015年  李俊. All rights reserved.
//

import CoreData
import SMKit

class OldCoreDataStack: NSObject {

  static let sharded: OldCoreDataStack = OldCoreDataStack()

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.likumb.EverMemo" in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
  }()

  lazy var managedObjectModel: NSManagedObjectModel? = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    if let modelURL = Bundle.main.url(forResource: "Memo", withExtension: "momd") {
      return NSManagedObjectModel(contentsOf: modelURL)
    }
    return nil
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    guard let modle = self.managedObjectModel else { return nil }
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: modle)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("Memo.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: Any]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      printLog(message: "Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }

    return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext? = {
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()

}

extension OldCoreDataStack {

  func fetchOldMemos() -> [Memo] {
    guard let context = self.managedObjectContext else {
      return [Memo]()
    }
    var memos = [Memo]()
    let memoFetch = Memo.defaultRequest()
    do {
      memos = try context.fetch(memoFetch)
    } catch let error as NSError {
      printLog(message: "\(error.userInfo)")
    }
    return memos
  }
}
