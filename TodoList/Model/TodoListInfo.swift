//
//  TodoListInfo.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 8/4/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import Foundation

struct TodoListInfo: Codable {
    var todos = [TodoItem]()
    
    struct TodoItem: Codable {
        let id = UUID().uuidString
        var description = ""
        var priority = 1 // Medium
        var dueDate = DueDate(year: 0, month: 0, day: 0, hour: 0, minute: 0, notificationId: "")
        var isCompleted = false
    }
    
    struct DueDate: Codable {
        var year : Int
        var month : Int
        var day : Int
        var hour : Int
        var minute : Int
        var notificationId : String
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(TodoListInfo.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    init(todoList: [TodoItem]) {
        self.todos = todoList
    }
}
