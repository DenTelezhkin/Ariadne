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

struct ExampleViewBuilder : ViewBuilder {
    struct BuildError: Error {}
    func build(with context: ExampleData) throws -> ExampleViewController {
        guard let controller = UIStoryboard(name: String(describing: ExampleViewController.self),
                                            bundle: nil).instantiateInitialViewController() as? ExampleViewController else {
            throw BuildError()
        }
        controller.exampleData = context
        return controller
    }
}

class ExampleViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var exampleData: ExampleData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textLabel.text = exampleData?.title
        actionButton.setTitle(exampleData?.buttonTitle, for: .normal)
    }

    @IBAction func buttonTapped() {
        exampleData?.buttonAction()
    }
}
