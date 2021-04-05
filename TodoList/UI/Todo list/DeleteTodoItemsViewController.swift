//
//  DeleteTodoItemsViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 8/4/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

protocol DeleteTodoItemsDelegate: AnyObject {
    func deleteCompletedTodoItems()
    func deleteAllTodoItems()
}
class DeleteTodoItemsViewController: UIViewController {
    
    weak var deleteTodoItemsDelegate: DeleteTodoItemsDelegate!
    
    @IBOutlet private weak var topLevelStackView: UIStackView!
    
    private let popoverWidthPadding: CGFloat = 30
    private let popoverHeightPadding: CGFloat = 30
    
    @IBAction func clearCompleted(_ sender: UIButton) {
        deleteTodoItemsDelegate.deleteCompletedTodoItems()
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func clearAll(_ sender: Any) {
        deleteTodoItemsDelegate.deleteAllTodoItems()
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let fittedSize = topLevelStackView.sizeThatFits(UIView.layoutFittingCompressedSize)
        preferredContentSize = CGSize(width: fittedSize.width + popoverWidthPadding,
                                      height: fittedSize.height + popoverHeightPadding)
    }
}
