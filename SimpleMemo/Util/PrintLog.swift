//
//  PrintLog.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation

public func printLog(message: String = "",
                     file: String = #file,
                     method: String = #function,
                     line: Int = #line) {
  #if DEBUG
    print("\(Date()) \((file as NSString).lastPathComponent)[\(line)L], \(method): \(message)")
  #endif
}
