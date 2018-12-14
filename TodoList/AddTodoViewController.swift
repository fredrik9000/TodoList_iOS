//
//  AddTodoViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 7/29/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

protocol CreateTodoItemDelegate: AnyObject {
    func createTodoItem(with todoItem: TodoListInfo.TodoItem)
}

class AddTodoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    weak var createTodoItemDelegate: CreateTodoItemDelegate!
    
    @IBOutlet weak var addTodoButton: UIButton!
    @IBOutlet weak var priorityPickerView: UIPickerView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var topLevelStackView: UIStackView!
    
    @IBAction func addTodoItem(_ sender: Any) {
        guard let description = descriptionTextField.text else {
            return
        }
        createTodoItemDelegate.createTodoItem(with: TodoListInfo.TodoItem(description: description, priority: priorityPickerView.selectedRow(inComponent: 0)))
        if let navController = self.navigationController {
            navController.dismiss(animated: true)
        } else {
            presentingViewController?.dismiss(animated: true)
        }
    }
    
    let popoverWidthPadding: CGFloat = 30
    let popoverHeightPadding: CGFloat = 30
    let priorities = ["Low priority", "Medium priority", "High priority"]
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            addTodoButton.isEnabled = true
        } else {
            addTodoButton.isEnabled = false
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorities[row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextField.addTarget(self, action: #selector(AddTodoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    //Adding a task will be done using a popover on tablets
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.navigationController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelController))
        } else {
            let fittedSize = topLevelStackView.sizeThatFits(UIView.layoutFittingCompressedSize)
            preferredContentSize = CGSize(width: fittedSize.width + popoverWidthPadding, height: fittedSize.height + popoverHeightPadding)
        }
    }
    
    @objc func cancelController(sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
