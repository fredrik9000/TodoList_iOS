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

    private var dateComponents: DateComponents!
    var todoItem: TodoListInfo.TodoItem!
    private var updateNotification = false
    private var removeNotification = false

    var positionInTodoList: Int! // Set when editing an item
    var isNewItem = false; // Set to true when adding an item

    weak var editTodoItemDelegate: EditTodoItemDelegate!
    weak var createTodoItemDelegate: CreateTodoItemDelegate!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var addTodoButton: UIBarButtonItem!
    @IBOutlet private weak var dueDateCell: UITableViewCell!

    @IBAction private func updateTodoItem(_ sender: Any) {
        guard let title = titleTextField.text else {
            return
        }

        if updateNotification {
            if removeNotification {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
                todoItem.dueDate.notificationId = ""
            } else {
                // For tasks without a notification we need to create a notification id.
                // If a task has an existing notification it will be removed before adding the new one.
                if todoItem.dueDate.notificationId == "" || notificationHasExpired(dueDate: todoItem.dueDate) {
                    todoItem.dueDate.notificationId = UUID().uuidString
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
                }

                let content = UNMutableNotificationContent()
                content.title = "Task reminder"
                content.body = title

                // Schedule the request with the system.
                UNUserNotificationCenter.current().add(
                    UNNotificationRequest(identifier: todoItem.dueDate.notificationId,
                                          content: content,
                                          trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                                                 repeats: false))
                ) { (error) in
                    if error != nil {
                        // TODO: Handle error.
                    }
                }
            }
        }

        todoItem.title = title
        todoItem.description = descriptionTextView.text

        if isNewItem {
            createTodoItemDelegate.createTodoItem(with: todoItem)
        } else {
            editTodoItemDelegate.updateTodoItem(with: todoItem, at: self.positionInTodoList)
        }

        self.navigationController?.popViewController(animated: true)
    }

    private func notificationHasExpired(dueDate: TodoListInfo.DueDate) -> Bool {
        return Calendar.current.date(from: DateComponents(year: dueDate.year,
                                                          month: dueDate.month,
                                                          day: dueDate.day,
                                                          hour: dueDate.hour,
                                                          minute: dueDate.minute))!.timeIntervalSinceNow.sign == .minus
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
        dueDateCell.detailTextLabel?.text = todoItem.dueDate.formattedDateString()
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
        if !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            addTodoButton.isEnabled = true
        } else {
            addTodoButton.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !isNewItem {
            titleTextField.text = todoItem.title
            addTodoButton.isEnabled = true

            descriptionTextView.text = todoItem.description

            if todoItem.priority == Priorities.lowPriority {
                priorityLabel.text = "Low"
            } else if todoItem.priority == Priorities.mediumPriority {
                priorityLabel.text = "Medium"
            } else {
                priorityLabel.text = "High"
            }
            if todoItem.dueDate.notificationId.count > 0 {
                dueDateCell.detailTextLabel?.text = todoItem.dueDate.formattedDateString()
            }
        } else {
            self.title = "Add task"
        }

        titleTextField.addTarget(self,
                                 action: #selector(EditTodoItemViewController.textFieldDidChange(_:)),
                                 for: UIControl.Event.editingChanged)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let priorityForCell = todoItem.priority
            if priorityForCell == Priorities.lowPriority {
                priorityLabel.textColor = Priorities.lowPriorityColor
            } else if priorityForCell == Priorities.mediumPriority {
                priorityLabel.textColor = Priorities.mediumPriorityColor
            } else if priorityForCell == Priorities.highPriority {
                priorityLabel.textColor = Priorities.highPriorityColor
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            // Switches to the next priority by tapping on the row
            if todoItem.priority == Priorities.lowPriority {
                priorityLabel.text = "Medium"
                todoItem.priority = Priorities.mediumPriority
                priorityLabel.textColor = Priorities.mediumPriorityColor
            } else if todoItem.priority == Priorities.mediumPriority {
                priorityLabel.text = "High"
                todoItem.priority = Priorities.highPriority
                priorityLabel.textColor = Priorities.highPriorityColor
            } else {
                priorityLabel.text = "Low"
                todoItem.priority = Priorities.lowPriority
                priorityLabel.textColor = Priorities.lowPriorityColor
            }

            self.tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.section == 3 {
            self.performSegue(withIdentifier: "Update Reminder", sender: indexPath)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Update Reminder" {
            if let dueDateViewController = segue.destination as? DueDateViewController {
                dueDateViewController.notificationDelegate = self
                if todoItem.dueDate.year != 0 {
                    dueDateViewController.notificationDate = todoItem.dueDate
                }
            }
        }
    }
}
