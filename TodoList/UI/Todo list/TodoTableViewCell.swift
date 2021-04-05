//
//  TodoTableViewCell.swift
//  TodoList
//
//  Created by Fredrik Eilertsen on 9/1/19.
//  Copyright © 2019 Fredrik Eilertsen. All rights reserved.
//

import UIKit
import BEMCheckBox

protocol CHeckBoxDelegate: AnyObject {
    func checkBoxTap(with todoId: String)
}

class TodoTableViewCell: UITableViewCell, BEMCheckBoxDelegate {

    weak var checkBoxDelegate: CHeckBoxDelegate?

    @IBOutlet weak var checkBox: BEMCheckBox!

    @IBOutlet weak var titleLabel: UILabel!

    var todoId = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.delegate = self
    }

    func didTap(_ checkBox: BEMCheckBox) {
        checkBoxDelegate!.checkBoxTap(with: todoId)
    }
}
