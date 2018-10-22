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
    case push
    case present
    
    var title: String {
        switch self {
        case .rootChange: return "Change root view"
        case .push: return "Push controller in navigation"
        case .present: return "Present controller modally"
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
    
    var window: UIWindow! {
        return UIApplication.shared.keyWindow
    }
    
    var finder: CurrentlyVisibleViewFinder {
        return CurrentlyVisibleViewFinder(window: window)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
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
        case .push: pushNewControllerInNavigation()
        case .present: presentControllerModally()
        }
    }
    
    func animateRootChange() {
        let transition = RootViewTransition(window: window)
        transition.animationOptions = .transitionCurlUp
        let switchRootRoute = Route(builder: RootViewControllerFactory(), transition: transition)
        router.navigate(to: switchRootRoute, with: ())
    }
    
    func pushNewControllerInNavigation() {
        let pushRoute = Route(builder: ExampleViewBuilder(), transition: PushNavigationTransition(finder: finder))
        let popRoute = Route(builder: NonBuilder(), transition: PopNavigationTransition(finder: finder))
        let model = ExampleData(title: "This is a pushed view controller", buttonTitle: "Pop back") { [weak self] in
            self?.router.navigate(to: popRoute, with: ())
        }
        router.navigate(to: pushRoute, with: model)
    }
    
    func presentControllerModally() {
        let presentRoute = Route(builder: ExampleViewBuilder(), transition: PresentationTransition(finder: finder))
        let dismissRoute = Route(builder: NonBuilder(), transition: DismissTransition(finder: finder))
        let model = ExampleData(title: "This is modally presented controller", buttonTitle: "Tap to dismiss") { [weak self] in
            self?.router.navigate(to: dismissRoute, with: ())
        }
        router.navigate(to: presentRoute, with: model)
    }
}
