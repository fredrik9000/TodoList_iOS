//
//  EditTodoItemViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 8/4/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit
import UserNotifications

protocol EditTodoItemDelegate: AnyObject {
    func updateTodoItem(with todoItem: TodoListInfo.TodoItem, at index: Int)
}

protocol CreateTodoItemDelegate: AnyObject {
    func createTodoItem(with todoItem: TodoListInfo.TodoItem)
}

class EditTodoItemViewController: UITableViewController, UITextFieldDelegate, NotificationDelegate {
    
    var dateComponents : DateComponents!
    var todoItem : TodoListInfo.TodoItem!
    var updateNotification = false
    var removeNotification = false
    
    let priorities = ["Low priority", "Medium priority", "High priority"]
    var positionInTodoList: Int! //Set when editing item
    var isNewItem = false; //Set to true when adding item
    
    let popoverWidthPadding: CGFloat = 30
    let popoverHeightPadding: CGFloat = 30
    
    weak var editTodoItemDelegate: EditTodoItemDelegate!
    weak var createTodoItemDelegate: CreateTodoItemDelegate!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var addTodoButton: UIBarButtonItem!
    
    @IBAction func updateTodoItem(_ sender: Any) {
        guard let description = descriptionTextField.text else {
            return
        }
        
        if updateNotification {
            if removeNotification {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
                todoItem.dueDate.notificationId = ""
            } else {
                let content = UNMutableNotificationContent()
                content.title = "Task reminder"
                content.body = description
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents, repeats: false)
                
                if todoItem.dueDate.notificationId == "" {
                    todoItem.dueDate.notificationId = UUID().uuidString
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
                }
                
                let request = UNNotificationRequest(identifier: todoItem.dueDate.notificationId,
                                                    content: content, trigger: trigger)
                
                // Schedule the request with the system.
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        // Handle any errors.
                    }
                }
            }
        }
        
        todoItem.description = description
        
        if isNewItem {
            createTodoItemDelegate.createTodoItem(with: todoItem)
        } else {
            editTodoItemDelegate.updateTodoItem(with: todoItem, at: self.positionInTodoList)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func prepareAddNotification(with date: Date) {
        updateNotification = true
        removeNotification = false
        dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        todoItem.dueDate.year = dateComponents.year!
        todoItem.dueDate.month = dateComponents.month!
        todoItem.dueDate.day = dateComponents.day!
        todoItem.dueDate.hour = dateComponents.hour!
        todoItem.dueDate.minute = dateComponents.minute!
    }
    
    func prepareRemoveNotification() {
        removeNotification = true
        updateNotification = true
        todoItem.dueDate.year = 0
        todoItem.dueDate.month = 0
        todoItem.dueDate.day = 0
        todoItem.dueDate.hour = 0
        todoItem.dueDate.minute = 0
    }
    
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
            descriptionTextField.text = todoItem.description
            addTodoButton.isEnabled = true
            
            if todoItem.priority == 0 {
                priorityLabel.text = "Low"
            } else if todoItem.priority == 1 {
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
            if todoItem.priority == 0 {
                priorityLabel.text = "Medium"
                todoItem.priority = 1
            } else if todoItem.priority == 1 {
                priorityLabel.text = "High"
                todoItem.priority = 2
            } else {
                priorityLabel.text = "Low"
                todoItem.priority = 0
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        } else if (indexPath.section == 2) {
            self.performSegue(withIdentifier: "Update Due Date", sender: indexPath)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Update Due Date" {
            if let vc = segue.destination as? DueDateViewController {
                vc.notificationDelegate = self
                if todoItem.dueDate.year != 0 {
                    vc.notificationDate = todoItem.dueDate
                }
            }
        }
    }
}
