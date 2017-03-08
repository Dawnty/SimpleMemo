//
//  CoreDataStack.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

  static let `default` = CoreDataStack()

  lazy var persistentContainer: NSPersistentContainer = {
    return self.fetchPersistentContainer(with: "SimpleMemo")
  }()

  lazy var managedContext: NSManagedObjectContext = {
    return self.persistentContainer.viewContext
  }()

  func saveContext () {
    if managedContext.hasChanges {
      do {
        try managedContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  func fetchPersistentContainer(with name: String) -> NSPersistentContainer {
    let container = NSPersistentContainer(name: name)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }

}
