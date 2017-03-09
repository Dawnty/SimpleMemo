//
//  Evernote.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import EvernoteSDK
import SMKit

var SimpleMemoNoteBook: ENNotebook?
private let bookName = "易便签"

extension ENSession {

  func fetchSimpleMemoNoteBook() {
    if !self.isAuthenticated { return }
    if let book: ENNotebook = SMStoreClient.fetchSimpleMemoNoteBook() as? ENNotebook {
      SimpleMemoNoteBook = book
      return
    }
    if let guid = SMStoreClient.getSimpleMemoNoteBookGuid() {
      fetchSimpleMemoNoteBook(with: guid)
    } else {
      createSimpleMemoNoteBook()
    }
  }

  /// 上传便签到印象笔记
  func uploadMemoToEvernote(_ memo: Memo) {
    guard let book = SimpleMemoNoteBook, self.isAuthenticated == true else {
      return
    }
    guard let text = memo.text, text.characters.count > 0 else {
      return
    }

    let note = ENNote()
    note.title = text.fetchTitle()
    note.content = ENNoteContent(string: text)

    if memo.noteRef == nil {
      self.upload(note, notebook: book, completion: { (noteRef, error) -> Void in
        if noteRef != nil {
          memo.noteRef = noteRef
          memo.isUpload = true
          CoreDataStack.default.saveContext()
        }
      })
    } else {
      self.upload(note, policy: .replaceOrCreate, to: book, orReplace: memo.noteRef, progress: nil, completion: { (noteRef, error) -> Void in
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

private extension ENSession {

  func fetchSimpleMemoNoteBook(with guid: String) {
    guard let client = self.primaryNoteStore() else { return }
    client.fetchNotebook(withGuid: guid, completion: { (book, error) in
      if let book = book {
        SimpleMemoNoteBook = ENNotebook(notebook: book)
        SMStoreClient.saveSimpleMemoNoteBook(book: book)
        printLog(message: "\(book)")
      } else if let error = error {
        printLog(message: error.localizedDescription)
      }
    })
  }

  func createSimpleMemoNoteBook() {
    guard let client = self.primaryNoteStore() else { return }
    let noteBook = EDAMNotebook()
    noteBook.name = bookName
    client.create(noteBook) { (book, error) in
      if let book = book {
        SimpleMemoNoteBook = ENNotebook(notebook: book)
        SMStoreClient.saveSimpleMemoNoteBook(book: book)
        SMStoreClient.saveSimpleMemoNoteBookGuid(with: book.guid)
        printLog(message: book.name)
      } else if let error = error {
        printLog(message: error.localizedDescription)
        self.findSimpleMemoNoteBook()
      }
    }
  }

  func findSimpleMemoNoteBook() {
    guard let client = self.primaryNoteStore() else { return }
    client.listNotebooks { (books, error) in
      if let books = books {
        for book in books {
          if book.name == bookName {
            SimpleMemoNoteBook = ENNotebook(notebook: book)
            SMStoreClient.saveSimpleMemoNoteBook(book: book)
            SMStoreClient.saveSimpleMemoNoteBookGuid(with: book.guid)
            printLog(message: "\(book)")
            break
          }
        }
      } else if let error = error {
        printLog(message: error.localizedDescription)
      }
    }
  }

}
