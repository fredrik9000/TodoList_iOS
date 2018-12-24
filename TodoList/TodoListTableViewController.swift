//
//  TableViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 7/29/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit
import UserNotifications

class TodoListTableViewController: UITableViewController, CreateTodoItemDelegate, UIPopoverPresentationControllerDelegate, DeleteTodoItemsDelegate, EditTodoItemDelegate {
    
    func deleteTodoItems(with priorities: [Bool]) {
        todoListInfo.todos = todoListInfo.todos.filter {
            if $0.priority == 0 {
                if (priorities[0]) {
                    if $0.dueDate.notificationId != "" {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0.dueDate.notificationId])
                    }
                    return false
                } else {
                    return true
                }
            } else if $0.priority == 1 {
                if (priorities[1]) {
                    if $0.dueDate.notificationId != "" {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0.dueDate.notificationId])
                    }
                    return false
                } else {
                    return true
                }
            } else if $0.priority == 2 {
                if (priorities[2]) {
                    if $0.dueDate.notificationId != "" {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [$0.dueDate.notificationId])
                    }
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        self.tableView.reloadData()
        saveList()
    }
    
    
    func createTodoItem(with todoItem: TodoListInfo.TodoItem) {
        todoListInfo.todos.append(todoItem)
        todoListInfo.todos.sort(by: {$0.priority > $1.priority})
        self.tableView.reloadData()
        saveList()
    }
    
    func updateTodoItem(with todoItem: TodoListInfo.TodoItem, at index: Int) {
        todoListInfo.todos[index] = todoItem
        todoListInfo.todos.sort(by: {$0.priority > $1.priority})
        self.tableView.reloadData()
        saveList()
    }
    
    var todoListInfo: TodoListInfo = TodoListInfo(todoList: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ).appendingPathComponent("TodoList.json") {
            if let jsonData = try? Data(contentsOf: url), let savedTodoListInfo = TodoListInfo(json: jsonData) {
                todoListInfo = savedTodoListInfo
                todoListInfo.todos.sort(by: {$0.priority > $1.priority})
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoListInfo.todos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let todoItem = todoListInfo.todos[indexPath.row]
        var cell : UITableViewCell
        if todoItem.dueDate.notificationId == "" {
            cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "todoCellWithNotification", for: indexPath)
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: todoItem.dueDate.year, month: todoItem.dueDate.month, day: todoItem.dueDate.day, hour: todoItem.dueDate.hour, minute: todoItem.dueDate.minute)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm"
            let formattedDate = formatter.string(from: calendar.date(from: components)!)
            cell.detailTextLabel?.text = "notify: \(formattedDate)"
        }

        cell.textLabel?.text = todoItem.description
        let priorityForCell = todoItem.priority
        if (priorityForCell == 0) {
            cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        } else if (priorityForCell == 1) {
            cell.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.8156862745, blue: 0.7529411765, alpha: 1)
        } else if (priorityForCell == 2) {
            cell.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.6980392157, blue: 0.5137254902, alpha: 1)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Edit TODO Item", sender: indexPath)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoItem = todoListInfo.todos[indexPath.row]
            if todoItem.dueDate.notificationId != "" {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todoItem.dueDate.notificationId])
            }
            todoListInfo.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveList()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add TODO Item" {
            if let vc = segue.destination as? EditTodoItemViewController {
                vc.createTodoItemDelegate = self
                vc.isNewItem = true
                vc.todoItem = TodoListInfo.TodoItem()
            }
        } else if segue.identifier == "Delete TODO items" {
            if let vc = segue.destination as? DeleteTodoItemsViewController {
                vc.deleteTodoItemsDelegate = self
                vc.popoverPresentationController?.delegate = self
            }
        } else if segue.identifier == "Edit TODO Item" {
            if let vc = segue.destination as? EditTodoItemViewController, let indexPath = sender as? IndexPath {
                vc.positionInTodoList = indexPath.row
                vc.todoItem = todoListInfo.todos[indexPath.row]
                vc.editTodoItemDelegate = self
            }
        }
    }

    func presentationController(_ controller: UIPresentationController,
    viewControllerForAdaptivePresentationStyle
    style: UIModalPresentationStyle) -> UIViewController? {
        let presented = controller.presentedViewController
        let navigationConroller = UINavigationController(rootViewController: presented)
        return navigationConroller
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func saveList() {
        if let json = todoListInfo.json {
            if let url = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
                ).appendingPathComponent("TodoList.json") {
                do {
                    try json.write(to: url)
                } catch let error {
                    print("Couldn't save \(error)")
                }
            }
        }
    }

}
