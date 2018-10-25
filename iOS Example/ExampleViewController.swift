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

struct ExampleViewBuilder : ViewBuilder, ViewUpdater {
    struct BuildError: Error {}
    func build(with context: ExampleData) throws -> ExampleViewController {
        guard let controller = UIStoryboard(name: String(describing: ExampleViewController.self),
                                            bundle: nil).instantiateInitialViewController() as? ExampleViewController else {
            throw BuildError()
        }
        controller.exampleData = context
        return controller
    }
    
    func findUpdatableView(for context: ExampleData) -> ExampleViewController? {
        return (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.viewControllers.last as? ExampleViewController
    }
}

class ExampleViewController: UIViewController, ContextUpdatable {
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
