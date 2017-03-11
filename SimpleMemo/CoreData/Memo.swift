//
//  Memo.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import CoreData
import EvernoteSDK

@objc(Memo)
public class Memo: NSManagedObject {

  @NSManaged public var text: String?
  @NSManaged public var noteRef: ENNoteRef?
  @NSManaged public var guid: String?
  @NSManaged public var isUpload: Bool
  @NSManaged public var createDate: Date?
  @NSManaged public var updateDate: Date?
  @NSManaged public var changeDate: Date?

}

extension Memo {
  public class func defaultRequest() -> NSFetchRequest<Memo> {
    return NSFetchRequest<Memo>(entityName: "Memo")
  }

  public class func newMemo() -> Memo {
    let context = CoreDataStack.default.managedContext
    let entityDescription = NSEntityDescription.entity(forEntityName: "Memo", in: context)
    let memo = Memo(entity: entityDescription!, insertInto: context)
    memo.createDate = Date()
    memo.isUpload = false
    return memo
  }
}
