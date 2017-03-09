//
//  Evernote.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import EvernoteSDK

extension ENSession {

  func fetchOrCreateSimpleMemoNoteBook() -> EDAMNotebook? {
    if !self.isAuthenticated { return nil }
    guard let client = self.primaryNoteStore() else { return nil }

    if let bookGuid: String = UserDefaults.standard.object(forKey: "SimpleMemoNoteBook") as? String {
      client.fetchNotebook(withGuid: bookGuid, completion: { (book, error) in
        if let book = book {
          printLog(message: "\(book)")
        } else if let error = error {
          printLog(message: error.localizedDescription)
        }
      })
    }

    let noteBook = EDAMNotebook()
    noteBook.name = "易便签"
    client.create(noteBook) { (book, error) in
      if let book = book {
        printLog(message: book.name)
      }

      if let error = error {
        printLog(message: error.localizedDescription)
        self.fetchSimpleMemoNoteBook()
      }
    }

    return nil
  }

  func fetchSimpleMemoNoteBook() -> EDAMNotebook? {
    guard let client = self.primaryNoteStore() else { return nil }
    client.listNotebooks { (books, error) in
      if let books = books {
        for book in books {
          if book.name == "易便签" {
            UserDefaults.standard.set(book.guid, forKey: "SimpleMemoNoteBook")
            printLog(message: "\(book)")
            break
          }
        }
      }
    }
    return nil
  }

  /// 上传便签到印象笔记
  func uploadMemoToEvernote(_ memo: Memo) {
    if self.isAuthenticated == false {
      return
    }
    guard let text = memo.text, text.characters.count > 0 else {
      return
    }

    let note = ENNote()
    note.title = text.fetchTitle()
    note.content = ENNoteContent(string: text)

    if memo.noteRef == nil {
      self.upload(note, notebook: nil, completion: { (noteRef, error) -> Void in
        if noteRef != nil {
          memo.noteRef = noteRef
          memo.isUpload = true
          CoreDataStack.default.saveContext()
        }
      })
    } else {
      self.upload(note, policy: .replaceOrCreate, to: nil, orReplace: memo.noteRef, progress: nil, completion: { (noteRef, error) -> Void in
        if noteRef != nil {
          memo.noteRef = noteRef
          memo.isUpload = true
          CoreDataStack.default.saveContext()
        }
      })
    }
  }

  /// 删除印象笔记中的便签
  func deleteFromEvernote(with memo: Memo) {
    if memo.noteRef == nil || !ENSession.shared.isAuthenticated {
      return
    }

    ENSession.shared.delete(memo.noteRef!, completion: { (error) -> Void in
      if error != nil {
        printLog(message: error.debugDescription)
      }
    })
  }

}
