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
    case findAndUpdateView
    case customTransitions
    case customPresentations
    case peekAndPop
    
    var title: String {
        switch self {
        case .rootChange: return "Change root view"
        case .push: return "Push controller in navigation"
        case .present: return "Present controller modally"
        case .findAndUpdateView: return "Find and update view"
        case .customTransitions: return "Custom navigation transitions"
        case .customPresentations: return "Custom presentation and dismissal"
        case .peekAndPop: return "Peek and Pop with 3D Touch"
        }
    }
}

private let kExampleCellReuseIdentifier = "ExampleReuseIdentifier"

class RootViewBuilder : ViewBuilder {
    func build(with context: ()) throws -> UINavigationController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController ?? .init()
    }
}

class ExamplesTableViewController: UITableViewController {
    
    lazy var router = Router(rootViewProvider: self.window)
    
    var window: UIWindow! {
        return UIApplication.shared.keyWindow
    }
    
    var transitioningToExample: Examples?
    
    var peekAndPopRoute : Route<ExampleViewBuilder,PushNavigationTransition>!
    var peekAndPopModel: ExampleData!

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kExampleCellReuseIdentifier)
        navigationController?.delegate = self
        
        peekAndPopRoute = router.pushNavigationRoute(with: ExampleViewBuilder())
        let popRoute = router.popNavigationRoute()
        peekAndPopModel = ExampleData(title: "This view can be peeked and popped", buttonTitle: "Tap to pop back to list") { [weak self] in
            self?.router.navigate(to: popRoute, with: ())
        }
        registerForPreviewing(with: self, sourceView: tableView)
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
        transitioningToExample = example
        switch example {
        case .rootChange: animateRootChange()
        case .push: pushNewControllerInNavigation()
        case .present: presentControllerModally()
        case .findAndUpdateView: findAndUpdateView()
        case .customTransitions: customNavigationTransitions()
        case .customPresentations: customPresentationAndDismissal()
        case .peekAndPop: router.navigate(to: peekAndPopRoute, with: peekAndPopModel)
        }
    }
    
    func animateRootChange() {
        let transition = RootViewTransition(window: window)
        transition.animationOptions = .transitionCurlUp
        let switchRootRoute = Route(builder: RootViewBuilder(), transition: transition)
        router.navigate(to: switchRootRoute, with: ())
    }
    
    func pushNewControllerInNavigation() {
        let pushRoute = router.pushNavigationRoute(with: ExampleViewBuilder())
        let popRoute = router.popNavigationRoute()
        let model = ExampleData(title: "This is a pushed view controller", buttonTitle: "Pop back") { [weak self] in
            self?.router.navigate(to: popRoute, with: ())
        }
        router.navigate(to: pushRoute, with: model)
    }
    
    func presentControllerModally() {
        let presentRoute = router.presentRoute(with: ExampleViewBuilder())
        let dismissRoute = router.dismissRoute()
        let model = ExampleData(title: "This is modally presented controller", buttonTitle: "Tap to dismiss") { [weak self] in
            self?.router.navigate(to: dismissRoute, with: ())
        }
        router.navigate(to: presentRoute, with: model)
    }
    
    func findAndUpdateView() {
        let pushRoute = router.pushNavigationRoute(with: ExampleViewBuilder())
        let popRoute = router.popNavigationRoute()
        let newModel = ExampleData(title: "Controller was updated with new data instead of pushing a new controller", buttonTitle: "Tap to go back to list of examples") { [weak self] in
            self?.router.navigate(to: popRoute, with: ())
        }
        let model = ExampleData(title: "This is a newly created view controller", buttonTitle: "Update with new model") { [weak self] in
            self?.router.updateOrNavigate(to: pushRoute, with: newModel)
        }
        router.navigate(to: pushRoute, with: model)
    }
    
    func customNavigationTransitions() {
        let pushRoute = router.pushNavigationRoute(with: ExampleViewBuilder())
        let popRoute = router.popNavigationRoute()
        let model = ExampleData(title: "This view was pushed with custom transition", buttonTitle: "Tap to pop with custom transition") { [weak self] in
            self?.router.navigate(to: popRoute, with: ())
        }
        router.navigate(to: pushRoute, with: model)
    }
    
    func customPresentationAndDismissal() {
        let presentRoute = router.presentRoute(with: ExampleViewBuilder())
        presentRoute.prepareForShowTransition = { [weak self] newView, transition, oldView in
            newView.transitioningDelegate = self
        }
        let dismissRoute = router.dismissRoute()
        let model = ExampleData(title: "This is modally presented view with custom animation", buttonTitle: "Tap to dismiss with custom animation") { [weak self] in
            self?.router.navigate(to: dismissRoute, with: ())
        }
        router.navigate(to: presentRoute, with: model)
    }
}

extension ExamplesTableViewController : UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaAnimator()
    }
}

extension ExamplesTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard transitioningToExample == Examples.customTransitions else { return nil }
        return AlphaAnimator()
    }
}

extension ExamplesTableViewController : UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath)
            else { return nil }
        guard let example = Examples(rawValue: indexPath.row), example == .peekAndPop else { return nil }
        previewingContext.sourceRect = cell.frame
        return try? peekAndPopRoute.builder.build(with: peekAndPopModel)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        peekAndPopRoute.transition.perform(with: viewControllerToCommit, on: self, completion: nil)
    }
}

class AlphaAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else { return }
        toView.alpha = 0
        container.addSubview(toView)
        
        UIView.animate(withDuration: 0.5, animations: {
            fromView.alpha = 0
            toView.alpha = 1
        }, completion: { finished in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled && finished)
        })
    }
    
}
