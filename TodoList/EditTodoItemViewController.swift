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

protocol CreateTodoItemDelegate: AnyObject {
    func createTodoItem(with todoItem: TodoListInfo.TodoItem)
}

class EditTodoItemViewController: UITableViewController, UITextFieldDelegate {
    
    weak var editTodoItemDelegate: EditTodoItemDelegate!
    weak var createTodoItemDelegate: CreateTodoItemDelegate!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var addTodoButton: UIBarButtonItem!
    
    @IBAction func updateTodoItem(_ sender: Any) {
        guard let description = descriptionTextField.text else {
            return
        }
        if isNewItem {
            createTodoItemDelegate.createTodoItem(with: TodoListInfo.TodoItem(description: description, priority: priority))
        } else {
            editTodoItemDelegate.updateTodoItem(with: TodoListInfo.TodoItem(description: description, priority: priority), at: self.positionInTodoList)
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    let popoverWidthPadding: CGFloat = 30
    let popoverHeightPadding: CGFloat = 30
    let priorities = ["Low priority", "Medium priority", "High priority"]
    
    var positionInTodoList: Int! //Set when editing item
    var priority = 1 //Set when editing item, default medium
    var todoDescription: String! //Set when editing item
    var isNewItem = false; //Set when adding item
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            addTodoButton.isEnabled = true
        } else {
            addTodoButton.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isNewItem {
            descriptionTextField.text = todoDescription
            addTodoButton.isEnabled = true
            
            if priority == 0 {
                priorityLabel.text = "Low"
            } else if priority == 1 {
                priorityLabel.text = "Medium"
            } else {
                priorityLabel.text = "High"
            }
        } else {
            self.title = "New TODO Item"
        }
        
        descriptionTextField.addTarget(self, action: #selector(EditTodoItemViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            if priority == 0 {
                priorityLabel.text = "Medium"
                priority = 1
            } else if priority == 1 {
                priorityLabel.text = "High"
                priority = 2
            } else {
                priorityLabel.text = "Low"
                priority = 0
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
