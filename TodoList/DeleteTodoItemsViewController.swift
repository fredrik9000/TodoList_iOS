//
//  DeleteTodoItemsViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 8/4/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

protocol DeleteTodoItemsDelegate: AnyObject {
    func deleteTodoItems(with priorities: [Bool])
}
class DeleteTodoItemsViewController: UIViewController {
    
    weak var deleteTodoItemsDelegate: DeleteTodoItemsDelegate!

    @IBOutlet private weak var lowPrioritySwitch: UISwitch!
    @IBOutlet private weak var mediumPrioritySwitch: UISwitch!
    @IBOutlet private weak var highPrioritySwitch: UISwitch!
    @IBOutlet private weak var deletePrioritesButton: UIButton!
    @IBOutlet private weak var topLevelStackView: UIStackView!
    
    private let popoverWidthPadding: CGFloat = 30
    private let popoverHeightPadding: CGFloat = 30
    
    @IBAction private func switchToggled(_ sender: UISwitch) {
        if lowPrioritySwitch.isOn || mediumPrioritySwitch.isOn || highPrioritySwitch.isOn {
            deletePrioritesButton.isEnabled = true
        } else {
            deletePrioritesButton.isEnabled = false
        }
    }
    
    @IBAction private func deletePriorites(_ sender: UIButton) {
        deleteTodoItemsDelegate.deleteTodoItems(with: [lowPrioritySwitch.isOn, mediumPrioritySwitch.isOn, highPrioritySwitch.isOn])
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let fittedSize = topLevelStackView.sizeThatFits(UIView.layoutFittingCompressedSize)
        preferredContentSize = CGSize(width: fittedSize.width + popoverWidthPadding, height: fittedSize.height + popoverHeightPadding)
    }
}
