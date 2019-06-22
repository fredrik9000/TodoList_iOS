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
    
    private var dateComponents : DateComponents!
    var todoItem : TodoListInfo.TodoItem!
    private var updateNotification = false
    private var removeNotification = false
    
    private let priorities = ["Low priority", "Medium priority", "High priority"]
    var positionInTodoList: Int! //Set when editing item
    var isNewItem = false; //Set to true when adding item

    weak var editTodoItemDelegate: EditTodoItemDelegate!
    weak var createTodoItemDelegate: CreateTodoItemDelegate!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var addTodoButton: UIBarButtonItem!
    @IBOutlet private weak var dueDateCell: UITableViewCell!
    
    @IBAction private func updateTodoItem(_ sender: Any) {
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
                
                if todoItem.dueDate.notificationId == "" || notificationHasExpired(dueDate: todoItem.dueDate) {
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
    
    private func createNotificationDateString() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: todoItem.dueDate.year, month: todoItem.dueDate.month, day: todoItem.dueDate.day, hour: todoItem.dueDate.hour, minute: todoItem.dueDate.minute)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm"
        return formatter.string(from: calendar.date(from: components)!)
    }
    
    private func notificationHasExpired(dueDate: TodoListInfo.DueDate) -> Bool {
        let components = DateComponents(year: dueDate.year, month: dueDate.month, day: dueDate.day, hour: dueDate.hour, minute: dueDate.minute)
        let someDateTime = Calendar.current.date(from: components)!
        return someDateTime.timeIntervalSinceNow.sign == .minus
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
        dueDateCell.detailTextLabel?.text = createNotificationDateString()
    }
    
    func prepareRemoveNotification() {
        removeNotification = true
        updateNotification = true
        todoItem.dueDate.year = 0
        todoItem.dueDate.month = 0
        todoItem.dueDate.day = 0
        todoItem.dueDate.hour = 0
        todoItem.dueDate.minute = 0
        dueDateCell.detailTextLabel?.text = "Not set"
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
            if todoItem.dueDate.notificationId.count > 0 {
                dueDateCell.detailTextLabel?.text = createNotificationDateString()
            }
        } else {
            self.title = "New TODO Item"
        }
        
        descriptionTextField.addTarget(self, action: #selector(EditTodoItemViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let priorityForCell = todoItem.priority
            if (priorityForCell == 0) {
                cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            } else if (priorityForCell == 1) {
                cell.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.8156862745, blue: 0.7529411765, alpha: 1)
            } else if (priorityForCell == 2) {
                cell.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.6980392157, blue: 0.5137254902, alpha: 1)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let myCell = tableView.cellForRow(at: indexPath)
            if todoItem.priority == 0 {
                priorityLabel.text = "Medium"
                todoItem.priority = 1
                myCell?.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.8156862745, blue: 0.7529411765, alpha: 1)
            } else if todoItem.priority == 1 {
                priorityLabel.text = "High"
                todoItem.priority = 2
                myCell?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.6980392157, blue: 0.5137254902, alpha: 1)
            } else {
                priorityLabel.text = "Low"
                todoItem.priority = 0
                myCell?.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
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
