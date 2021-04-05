//
//  DueDateViewController.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 12/21/18.
//  Copyright © 2018 Fredrik Eilertsen. All rights reserved.
//

import UIKit

protocol NotificationDelegate: AnyObject {
    func prepareAddNotification(with date: Date)
    func prepareRemoveNotification()
}

class DueDateViewController: UIViewController {
    
    weak var notificationDelegate: NotificationDelegate!
    
    @IBOutlet private weak var removeDueDateButton: UIButton!
    @IBOutlet private weak var addDueDateButton: UIButton!
    @IBOutlet private weak var datePicker: UIDatePicker!
    var notificationDate: TodoListInfo.DueDate?
    
    @IBAction private func removeDueDate(_ sender: Any) {
        notificationDelegate.prepareRemoveNotification()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func addDueDate(_ sender: Any) {
        notificationDelegate.prepareAddNotification(with: datePicker.date)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dueDate = notificationDate {
            let components = DateComponents(year: dueDate.year,
                                            month: dueDate.month,
                                            day: dueDate.day,
                                            hour: dueDate.hour,
                                            minute: dueDate.minute)
            datePicker.setDate(Calendar(identifier: .gregorian).date(from: components)!, animated: false)
        }
        datePicker.minimumDate = Date()
    }
}
