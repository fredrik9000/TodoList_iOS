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
        var description = ""
        var priority = 0
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
