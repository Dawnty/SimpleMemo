//
//  MemoViewController.swift
//  EverMemo
//
//  Created by  李俊 on 15/8/5.
//  Copyright (c) 2015年  李俊. All rights reserved.
//

import UIKit
import CoreData
import EvernoteSDK
import SnapKit
import SMKit

class MemoViewController: UIViewController {

  var memo: Memo?

  fileprivate let textView = UITextView()
  fileprivate var sharedItem: UIBarButtonItem!

  convenience init(text: String? = nil) {
    self.init(nibName: nil, bundle: nil)
    textView.text = text ?? ""
    saveCurrentText()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
    NotificationCenter.default.addObserver(self, selector: #selector(changeLayOut(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
    if let memo = memo, textView.text.isEmpty {
      ENSession.shared.deleteFromEvernote(with: memo)
      CoreDataStack.default.managedContext.delete(memo)
    }
    CoreDataStack.default.saveContext()
  }

  // 3D Touch previewActionItems
  override var previewActionItems: [UIPreviewActionItem] {
    let deleteAction = UIPreviewAction(title: "删除", style: .destructive) { (action, controller) in
      guard let memoController: MemoViewController = controller as? MemoViewController, let memo = memoController.memo else {
        return
      }

      CoreDataStack.default.managedContext.delete(memo)
      ENSession.shared.deleteFromEvernote(with: memo)
    }
    return [deleteAction]
  }

}

// MARK: - Private extension

private extension MemoViewController {

  func setUI() {
    view.backgroundColor = UIColor.white
    setTextView()
    sharedItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(MemoViewController.perpormShare(_:)))
    navigationItem.rightBarButtonItem = sharedItem
    if memo == nil {
      title = "新便签"
      textView.becomeFirstResponder()
    } else {
      title = memo!.text?.fetchTitle()
      textView.text = memo!.text
    }
    sharedItem.isEnabled = !textView.text.isEmpty
  }

  func setTextView() {
    textView.delegate = self
    textView.layoutManager.allowsNonContiguousLayout = false
    textView.keyboardDismissMode = .onDrag
    textView.translatesAutoresizingMaskIntoConstraints = false
    setTextViewAttrubt()
    view.addSubview(textView)
    setTextViewConstraints(withBottomOffset: -5)
  }

  func setTextViewConstraints(withBottomOffset offset: CGFloat) {
    textView.snp.remakeConstraints { (maker) in
      maker.top.equalToSuperview()
      maker.left.equalTo(view).offset(5)
      maker.right.equalTo(view).offset(-5)
      maker.bottom.equalTo(view).offset(offset)
    }
  }

  func setTextViewAttrubt() {
    let paregraphStyle = NSMutableParagraphStyle()
    paregraphStyle.lineSpacing = 5
    let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSParagraphStyleAttributeName: paregraphStyle]
    textView.typingAttributes = attributes
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.textColor = SMColor.content
  }

  @objc func perpormShare(_ barButton: UIBarButtonItem) {
    let activityController = UIActivityViewController(activityItems: [textView.text], applicationActivities: nil)
    let drivce = UIDevice.current
    let model = drivce.model
    if model == "iPhone Simulator" || model == "iPhone" || model == "iPod touch"{
      present(activityController, animated: true, completion: nil)
    } else {
      let popoverView =  UIPopoverController(contentViewController: activityController)
      popoverView.present(from: barButton, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    }
  }

  @objc func changeLayOut(_ notification: Notification) {
    let keyboarFrame: CGRect? = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
    let keyboardY = keyboarFrame?.origin.y ?? 0
    setTextViewConstraints(withBottomOffset: -(view.bounds.size.height - keyboardY + 5))
  }

  func saveCurrentText() {
    memo = memo ?? Memo.newMemo()
    memo!.text = textView.text
    memo!.updateDate = Date()
    CoreDataStack.default.saveContext()
  }

}

// MARK: - UITextViewDelegate

extension MemoViewController: UITextViewDelegate {

  func textViewDidChange(_ textView: UITextView) {
    memo?.isUpload = false
    sharedItem.isEnabled = !textView.text.isEmpty
    saveCurrentText()
  }

}
