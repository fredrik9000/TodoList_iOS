//
//  TodoListTableViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 7/29/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit
import UserNotifications

class TodoListTableViewController: UITableViewController, CreateTodoItemDelegate, UIPopoverPresentationControllerDelegate, DeleteTodoItemsDelegate, EditTodoItemDelegate, CHeckBoxDelegate {

    private var todoListInfo = TodoListInfo(todoList: [])

    // Keeps track of whether viewWillAppear() happened without viewDidLoad() in which case we need to reload table data
    private var isViewJustLoaded = false

    func deleteCompletedTodoItems() {
        todoListInfo.todos = todoListInfo.todos.filter {
            if $0.isCompleted {
                removeNotificationIfPresent(with: $0.dueDate.notificationId)
                return false
            } else {
                return true
            }
        }
        self.tableView.reloadData()
        saveList()
    }

    func deleteAllTodoItems() {
        todoListInfo.todos.forEach {
            removeNotificationIfPresent(with: $0.dueDate.notificationId)
        }

        todoListInfo.todos = []
        self.tableView.reloadData()
        saveList()
    }

    private func removeNotificationIfPresent(with notificationId: String) {
        if notificationId != "" {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        }
    }

    func createTodoItem(with todoItem: TodoListInfo.TodoItem) {
        todoListInfo.todos.append(todoItem)
        sortList()
        self.tableView.reloadData()
        saveList()
    }

    func updateTodoItem(with todoItem: TodoListInfo.TodoItem, at index: Int) {
        todoListInfo.todos[index] = todoItem
        sortList()
        self.tableView.reloadData()
        saveList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isViewJustLoaded = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isViewJustLoaded {
            self.tableView.reloadData()
        }
        isViewJustLoaded = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        loadPersistedJsonData()
    }

    private func loadPersistedJsonData() {
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TodoList.json") {
            if let jsonData = try? Data(contentsOf: url), let savedTodoListInfo = TodoListInfo(json: jsonData) {
                todoListInfo = savedTodoListInfo
                sortList()
            }
        }
    }

    private func saveList() {
        if let json = todoListInfo.json, let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TodoList.json") {
            do {
                try json.write(to: url)
            } catch let error {
                print("Couldn't save: \(error)")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todoListInfo.todos.count == 0 {
            self.tableView.setEmptyMessage("Add tasks by tapping the plus-button.")
        } else {
            self.tableView.restore()
        }

        return todoListInfo.todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todoItem = todoListInfo.todos[indexPath.row]
        if todoItem.dueDate.notificationId == "" || notificationHasExpired(dueDate: todoItem.dueDate) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell

            cell.titleLabel!.text = todoItem.title
            cell.titleLabel!.isEnabled = !todoItem.isCompleted
            cell.todoId = todoItem.id

            configureCellCheckbox(cell: cell,
                                  isCompleted: todoItem.isCompleted,
                                  priority: todoItem.priority,
                                  row: indexPath.row)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoNotificationCell",
                                                     for: indexPath) as! TodoWithNotificationTableViewCell
            
            cell.notificationLabel!.text = "Remind me: \(todoItem.dueDate.formattedDateString())"
            cell.titleLabel!.text = todoItem.title
            cell.titleLabel!.isEnabled = !todoItem.isCompleted
            cell.notificationLabel!.isEnabled = !todoItem.isCompleted
            cell.todoId = todoItem.id

            configureCellCheckbox(cell: cell,
                                  isCompleted: todoItem.isCompleted,
                                  priority: todoItem.priority,
                                  row: indexPath.row)

            return cell
        }
    }

    private func configureCellCheckbox(cell: TodoTableViewCell, isCompleted: Bool, priority: Int, row: Int) {
        cell.checkBox.on = isCompleted
        cell.checkBoxDelegate = self
        let color = priority == Priorities.lowPriority ? Priorities.lowPriorityColor :
            priority == Priorities.mediumPriority ? Priorities.mediumPriorityColor :
            Priorities.highPriorityColor
        cell.checkBox.tintColor = color
        cell.checkBox.onCheckColor = color
        cell.checkBox.onTintColor = color
    }

    func checkBoxTap(with todoId: String) {
        // In order to let the checkbox animation finish, a delay of 300 millisenconds is used
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let oldPosition = self.findTodoPosition(id: todoId)
            let cell = self.tableView.cellForRow(at: IndexPath(row: oldPosition, section: 0)) as! TodoTableViewCell

            let notificationId = self.todoListInfo.todos[oldPosition].dueDate.notificationId
            if notificationId != "" {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
                self.todoListInfo.todos[oldPosition].dueDate.notificationId = ""
                self.todoListInfo.todos[oldPosition].dueDate.year = 0
                self.todoListInfo.todos[oldPosition].dueDate.month = 0
                self.todoListInfo.todos[oldPosition].dueDate.day = 0
                self.todoListInfo.todos[oldPosition].dueDate.hour = 0
                self.todoListInfo.todos[oldPosition].dueDate.minute = 0
            }

            self.todoListInfo.todos[oldPosition].isCompleted = cell.checkBox.on

            // Reorder the list and move the checked/unchecked todo item to the new position
            let todo = self.todoListInfo.todos[oldPosition]
            self.todoListInfo.todos.remove(at: oldPosition)
            self.tableView.deleteRows(at: [IndexPath(row: oldPosition, section: 0)], with: UITableView.RowAnimation.fade)
            if let index = self.todoListInfo.todos.firstIndex(where: { self.sortOrder(todo1: todo, todo2: $0) }) {
                self.todoListInfo.todos.insert(todo, at: index)
            } else { // Shouldn't happen
                self.todoListInfo.todos.insert(todo, at: 0)
                self.sortList()
            }
            let newPosition = self.findTodoPosition(id: todoId)
            self.tableView.insertRows(at: [IndexPath(row: newPosition, section: 0)], with: UITableView.RowAnimation.fade)
        }
    }

    func findTodoPosition(id: String) -> Int {
        if let index = todoListInfo.todos.firstIndex(where: { $0.id == id }) {
            return index
        } else {
            return 0 // Shouldn't be possible
        }
    }

    private func notificationHasExpired(dueDate: TodoListInfo.DueDate) -> Bool {
        return Calendar.current.date(from: DateComponents(year: dueDate.year,
                                                          month: dueDate.month,
                                                          day: dueDate.day,
                                                          hour: dueDate.hour,
                                                          minute: dueDate.minute))!.timeIntervalSinceNow.sign == .minus
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Row should not be selectable if the task is completed
        if todoListInfo.todos[indexPath.row].isCompleted {
            return nil
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Edit TODO Item", sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoItem = todoListInfo.todos[indexPath.row]
            if todoItem.dueDate.notificationId != "" {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
            }
            todoListInfo.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveList()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add TODO Item" {
            if let editTodoItemViewController = segue.destination as? EditTodoItemViewController {
                editTodoItemViewController.createTodoItemDelegate = self
                editTodoItemViewController.isNewItem = true
                editTodoItemViewController.todoItem = TodoListInfo.TodoItem()
            }
        } else if segue.identifier == "Edit TODO Item" {
            if let editTodoItemViewController = segue.destination as? EditTodoItemViewController, let indexPath = sender as? IndexPath {
                editTodoItemViewController.positionInTodoList = indexPath.row
                editTodoItemViewController.todoItem = todoListInfo.todos[indexPath.row]
                editTodoItemViewController.editTodoItemDelegate = self
            }
        } else if segue.identifier == "Delete TODO items" {
            if let deleteTodoItemsViewController = segue.destination as? DeleteTodoItemsViewController {
                deleteTodoItemsViewController.deleteTodoItemsDelegate = self
                deleteTodoItemsViewController.popoverPresentationController?.delegate = self
            }
        }
    }

    func presentationController(_ controller: UIPresentationController,
                                viewControllerForAdaptivePresentationStyle
        style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func sortList() {
        todoListInfo.todos.sort(by: {
            sortOrder(todo1: $0, todo2: $1)
        })
    }

    func sortOrder(todo1: TodoListInfo.TodoItem, todo2: TodoListInfo.TodoItem) -> Bool {
        if todo1.isCompleted != todo2.isCompleted {
            return !todo1.isCompleted
        } else if todo1.priority != todo2.priority {
            return todo1.priority > todo2.priority
        } else if todo1.title != todo2.title {
            return todo1.title < todo2.title
        } else {
            return true
        }
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 40)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
