//
//  SMStoreClient.swift
//  SimpleMemo
//
//  Created by 李俊 on 2017/3/9.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation

public class SMStoreClient {

  public static let shared = UserDefaults(suiteName: "group.likumb.simpleMemo")!

  private struct Keys {
    static let SimpleMemoNoteBookGuid = "SimpleMemoNoteBookGuid"
    static let SimpleMemoNoteBookPath = "xyz.lijun.simpleMemo"
  }

  public static func saveSimpleMemoNoteBookGuid(with guid: String) {
    shared.set(guid, forKey: Keys.SimpleMemoNoteBookGuid)
    shared.synchronize()
  }

  public static func getSimpleMemoNoteBookGuid() -> String? {
    return shared.string(forKey: Keys.SimpleMemoNoteBookGuid)
  }

  public static func saveSimpleMemoNoteBook<T: NSCoding>(book: T) {
    let data = NSKeyedArchiver.archivedData(withRootObject: book)
    shared.set(data, forKey: Keys.SimpleMemoNoteBookPath)
  }

  public static func fetchSimpleMemoNoteBook() -> Any? {
    guard let data = shared.data(forKey: Keys.SimpleMemoNoteBookPath) else {
      return nil
    }
    return NSKeyedUnarchiver.unarchiveObject(with: data)
  }
  
}
