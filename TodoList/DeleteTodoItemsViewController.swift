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

    @IBOutlet weak var lowPrioritySwitch: UISwitch!
    @IBOutlet weak var mediumPrioritySwitch: UISwitch!
    @IBOutlet weak var highPrioritySwitch: UISwitch!
    @IBOutlet weak var deletePrioritesButton: UIButton!
    @IBOutlet weak var topLevelStackView: UIStackView!
    
    let popoverWidthPadding: CGFloat = 30
    let popoverHeightPadding: CGFloat = 30
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        if lowPrioritySwitch.isOn || mediumPrioritySwitch.isOn || highPrioritySwitch.isOn {
            deletePrioritesButton.isEnabled = true
        } else {
            deletePrioritesButton.isEnabled = false
        }
    }
    
    @IBAction func deletePriorites(_ sender: UIButton) {
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
