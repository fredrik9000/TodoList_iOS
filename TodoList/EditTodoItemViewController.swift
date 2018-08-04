//
//  EditTodoItemViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 8/4/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

protocol EditTodoItemDelegate: AnyObject {
    func updateTodoItem(with todoItem: TodoListInfo.TodoItem, at index: Int)
}
class EditTodoItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    weak var editTodoItemDelegate: EditTodoItemDelegate!

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var topLevelStackView: UIStackView!
    @IBOutlet weak var priorityPickerView: UIPickerView!
    @IBOutlet weak var addTodoButton: UIButton!
    @IBAction func updateTodoItem(_ sender: Any) {
        guard let description = descriptionTextField.text else {
            return
        }
        editTodoItemDelegate.updateTodoItem(with: TodoListInfo.TodoItem(description: description, priority: priorityPickerView.selectedRow(inComponent: 0)), at: self.index)
        self.navigationController?.popViewController(animated: true)
    }

    let popoverWidthPadding: CGFloat = 30
    let popoverHeightPadding: CGFloat = 30
    let priorities = ["Low priority", "Medium priority", "High priority"]
    var index: Int!
    var priority: Int!
    var todoDescription: String!
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(descriptionTextField.text?.isEmpty)! {
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

        priorityPickerView.selectRow(priority, inComponent: 0, animated: false)
        descriptionTextField.text = todoDescription
        descriptionTextField.addTarget(self, action: #selector(AddTodoViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
}
