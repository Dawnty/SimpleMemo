//
//  String+Extension'.swift
//  SimpleMemo
//
//  Created by 李俊 on 2017/3/11.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation

public extension String {

  var attributedStringFromHTML: NSAttributedString? {
    guard let data = data(using: .utf8) else { return nil }
    do {
      return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
    } catch let error as NSError {
      printLog(message: error.localizedDescription)
      return  nil
    }
  }
  var stringFromHTML: String {
    return attributedStringFromHTML?.string ?? ""
  }
}
