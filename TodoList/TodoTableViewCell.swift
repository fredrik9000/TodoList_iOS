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
    func checkBoxTap(with tag: Int)
}

class TodoTableViewCell: UITableViewCell, BEMCheckBoxDelegate {

    weak var checkBoxDelegate : CHeckBoxDelegate?
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.delegate = self
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        checkBoxDelegate!.checkBoxTap(with: checkBox.tag)
    }

}
