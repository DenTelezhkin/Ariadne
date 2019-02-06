//
//  ExampleViewController.swift
//  iOS Example
//
//  Created by Denys Telezhkin on 10/22/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import UIKit
import Ariadne

struct ExampleData {
    let title: String?
    let buttonTitle: String?
    let buttonAction: () -> ()
}

class ExampleViewController: UIViewController, ContextUpdatable, Buildable {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var exampleData: ExampleData? {
        didSet {
            loadViewIfNeeded()
            textLabel.text = exampleData?.title
            actionButton.setTitle(exampleData?.buttonTitle, for: .normal)
        }
    }
    
    func update(with context: ExampleData) {
        exampleData = context
    }

    @IBAction func buttonTapped() {
        exampleData?.buttonAction()
    }
}
