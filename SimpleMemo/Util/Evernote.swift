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

var SimpleMemoNoteBook: ENNotebook? {
  didSet {
    ENSession.shared.downloadNotesInSimpleMemoNotebook(with: nil)
  }
}

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

  func downloadNotesInSimpleMemoNotebook(with compeletion: ((_ notesResults: [ENSessionFindNotesResult]?, _ error: NSError?) -> Void)?) {
    findNotes(with: nil, in: SimpleMemoNoteBook, orScope: .personal, sortOrder: .recentlyUpdated, maxResults: 0) { (results, error) in
      if let results = results {
        for result in results {
          printLog(message: "\(result)")
        }
      }
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

    guard let storeClient = self.noteStore(for: book) else { return }
    let amnote = EDAMNote()
    amnote.title = text.fetchTitle()
    amnote.notebookGuid = book.guid
    amnote.content = ENNoteContent(string: text).enml
    var guid: String?
    if memo.guid != nil {
      guid = memo.guid
    } else if memo.noteRef != nil {
      guid = memo.noteRef?.guid
    }

    if let guid = guid {
      amnote.guid = guid
      storeClient.update(amnote, completion: { [weak self] (note, error) in
        if let note = note {
          self?.updateMemo(memo, with: note)
          printLog(message: "\(note)")
        } else if let error = error {
          printLog(message: error.localizedDescription)
        }
      })
    } else {
      storeClient.create(amnote) { [weak self] (note, error) in
        if let note = note {
          self?.updateMemo(memo, with: note)
          printLog(message: "\(note)")
        } else if let error = error {
          printLog(message: error.localizedDescription)
        }
      }
    }
  }

  func updateMemo(_ memo: Memo, with note: EDAMNote) {
    let createDate = NSDate(edamTimestamp: note.created.int64Value) as Date
    let updateDate = NSDate(edamTimestamp: note.updated.int64Value) as Date
    memo.createDate = createDate
    memo.updateDate = updateDate
    memo.guid = note.guid
    memo.isUpload = true
    CoreDataStack.default.saveContext()
  }

  /// 删除印象笔记中的便签
  func deleteFromEvernote(with memo: Memo) {
    if (memo.noteRef == nil && memo.guid == nil) || !ENSession.shared.isAuthenticated {
      return
    }
    let guid = memo.guid ?? memo.noteRef?.guid
    guard let storeClient = self.primaryNoteStore(), let noteGuid = guid else { return }
    storeClient.deleteNote(withGuid: noteGuid) { (_, error) in
      if let error = error {
        printLog(message: error.localizedDescription)
      }
    }
  }

}

private extension ENSession {

  func fetchSimpleMemoNoteBook(with guid: String) {
    guard let client = self.primaryNoteStore() else { return }
    client.fetchNotebook(withGuid: guid, completion: { (book, error) in
      if let book = book {
        let notebook = ENNotebook(notebook: book)
        SimpleMemoNoteBook = notebook
        SMStoreClient.saveSimpleMemoNoteBook(book: notebook)
        printLog(message: "\(notebook)")
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
        let notebook = ENNotebook(notebook: book)
        SimpleMemoNoteBook = notebook
        SMStoreClient.saveSimpleMemoNoteBook(book: notebook)
        SMStoreClient.saveSimpleMemoNoteBookGuid(with: book.guid)
        printLog(message: "\(notebook)")
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
            let notebook = ENNotebook(notebook: book)
            SimpleMemoNoteBook = notebook
            SMStoreClient.saveSimpleMemoNoteBook(book: notebook)
            SMStoreClient.saveSimpleMemoNoteBookGuid(with: book.guid)
            printLog(message: "\(notebook)")
            break
          }
        }
      } else if let error = error {
        printLog(message: error.localizedDescription)
      }
    }
  }

}
