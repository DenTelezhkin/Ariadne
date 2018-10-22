//
//  ExamplesTableViewController.swift
//  iOS Example
//
//  Created by Denys Telezhkin on 10/22/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import UIKit
import Ariadne

enum Examples: Int, CaseIterable {
    case rootChange
    
    var title: String {
        switch self {
        case .rootChange: return "Change root view"
        }
    }
}

private let kExampleCellReuseIdentifier = "ExampleReuseIdentifier"

class RootViewControllerFactory : ViewBuilder {
    func build(with context: ()) throws -> UINavigationController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController ?? .init()
    }
}

class ExamplesTableViewController: UITableViewController {
    
    let router = Router()

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kExampleCellReuseIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Examples.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kExampleCellReuseIdentifier, for: indexPath)
        guard let example = Examples(rawValue: indexPath.row) else {
            fatalError("Unsupported example")
        }
        cell.textLabel?.text = example.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let example = Examples(rawValue: indexPath.row) else {
            fatalError("Unsupported example")
        }
        switch example {
        case .rootChange: animateRootChange()
        }
    }
    
    func animateRootChange() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let transition = RootViewTransition(window: window)
        transition.animationOptions = .transitionCurlUp
        let switchRootRoute = Route(builder: RootViewControllerFactory(), transition: transition)
        router.navigate(to: switchRootRoute, with: ())
    }
}
