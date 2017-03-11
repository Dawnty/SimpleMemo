//
//  SMNotification.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/27.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation

public struct SMNotification {
  public static let MemoCellShouldHiddenDeleteBtn = NSNotification.Name("MemoCellShouldHiddenDeleteBtn")
  public static let MemoCellDidShowDeleteBtn = NSNotification.Name("MemoCellDidShowDeleteBtn")
  public static let SimpleMemoDidSetSimpleMemoNotebook = NSNotification.Name("SimpleMemoDidSetSimpleMemoNotebook")
}
