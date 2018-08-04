//
//  TableViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 7/29/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController, CreateTodoItemDelegate, UIPopoverPresentationControllerDelegate, DeleteTodoItemsDelegate {
    
    func deleteTodoItems(with priorities: [Bool]) {
        todoListInfo.todos = todoListInfo.todos.filter {
            if $0.priority == 0 {
                return !priorities[0]
            } else if $0.priority == 1 {
                return !priorities[1]
            } else if $0.priority == 2 {
                return !priorities[2]
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
    
    var todoListInfo: TodoListInfo = TodoListInfo(todoList: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)

        cell.textLabel?.text = todoListInfo.todos[indexPath.row].description
        cell.detailTextLabel?.text = String(todoListInfo.todos[indexPath.row].priority)
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTodo" {
            if let vc = segue.destination as? AddTodoViewController {
                vc.createTodoItemDelegate = self
                vc.popoverPresentationController?.delegate = self
            }
        } else if segue.identifier == "Delete todo items" {
            if let vc = segue.destination as? DeleteTodoItemsViewController {
                vc.deleteTodoItemsDelegate = self
                vc.popoverPresentationController?.delegate = self
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
        if ((controller.presentedViewController as? AddTodoViewController) != nil) {
            return UIModalPresentationStyle.fullScreen
        } else {
            return UIModalPresentationStyle.none
        }
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
