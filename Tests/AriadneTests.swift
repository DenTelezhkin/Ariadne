//
//  AriadneTests.swift
//  AriadneTests
//
//  Created by Denys Telezhkin on 10/1/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import Ariadne
import UIKit

class XibBuildingFactory<T:View> : ViewBuilder {
    func build(with context: ()) throws -> T {
        return T(nibName: nil, bundle: nil)
    }
}

class FooViewController: UIViewController {
    var dismissCalled = false
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
        super.dismiss(animated: flag, completion: completion)
    }
}
class BarViewController: UIViewController {
    
    var dismissCalled = false
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
        super.dismiss(animated: flag, completion: completion)
    }
}

class IntViewController : UIViewController, ContextUpdatable {
    
    var value: Int = 0
    var wasUpdated : Bool = false
    var wasCreated: Bool = true
    
    init(value: Int) {
        self.value = value
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(with context: Int) {
        value = context
        wasCreated = false
        wasUpdated = true
    }
}

class IntFactory : ViewBuilder, ViewUpdater {
    
    let window : UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func build(with context: Int) throws -> IntViewController {
        return IntViewController(value: context)
    }
    
    func findUpdatableView(for context: Int) -> IntViewController? {
        return CurrentlyVisibleViewFinder(rootViewProvider: window).currentlyVisibleView() as? IntViewController
    }
}

class AriadneTests: XCTestCase {
    
    var root: View? {
        return testableWindow?.rootViewController
    }
    
    var testableWindow : UIWindow!
    let router = Router()

    override func setUp() {
        super.setUp()
        testableWindow = UIWindow(frame: UIScreen.main.bounds)
        testableWindow.isHidden = false
        testableWindow.rootViewController = BarViewController()
    }
    
    func testPushTransition() {
        let pushRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                              transition: PushNavigationTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow)))
        testableWindow?.rootViewController = UINavigationController()
        router.navigate(to: pushRoute, with: ())
        
        XCTAssertEqual((root as? UINavigationController)?.viewControllers.count, 1)
    }
    
    func testPopTransition() {
        let exp = expectation(description: "NavigationCompletion")
        let popRoute = Route(builder: NonBuilder(),
                              transition: PopNavigationTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow)))
        popRoute.transition.isAnimated = false
        let navigation = UINavigationController()
        navigation.setViewControllers([FooViewController(),FooViewController()], animated: false)
        testableWindow?.rootViewController = navigation
        router.navigate(to: popRoute, with: ()) { result in
            if result {
                XCTAssertEqual((self.root as? UINavigationController)?.viewControllers.count, 1)
                exp.fulfill()
            } else {
                XCTFail("failed to perform transition")
            }
        }
        waitForExpectations(timeout: 0.1)
    }
    
    func testRootViewTransition() {
        let switchRootViewRoute = Route(builder: XibBuildingFactory<FooViewController>(), transition: RootViewTransition(window: testableWindow))
        switchRootViewRoute.transition.isAnimated = false
        router.navigate(to: switchRootViewRoute, with: ())
        
        XCTAssert(testableWindow.rootViewController is FooViewController)
    }
    
    func testPresentationTransition() {
        let presentExpectation = expectation(description: "Presentation expectation")
        let presentationRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                                      transition: PresentationTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow)))
        presentationRoute.transition.isAnimated = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(self.testableWindow.rootViewController is BarViewController)
            XCTAssert(self.testableWindow.rootViewController?.presentedViewController is FooViewController)
            presentExpectation.fulfill()
        }
        router.navigate(to: presentationRoute, with: ())
        waitForExpectations(timeout: 0.2)
    }

    func testDismissTransition() {
        let presentExpectation = expectation(description: "Presentation expectation")
        let presentationRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                                      transition: PresentationTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow)))
        presentationRoute.transition.isAnimated = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(self.testableWindow.rootViewController is BarViewController)
            XCTAssert(self.testableWindow.rootViewController?.presentedViewController is FooViewController)
            presentExpectation.fulfill()
        }
        router.navigate(to: presentationRoute, with: ())
        waitForExpectations(timeout: 0.2)
        
        let dismissalRoute = Route(builder: NonBuilder(), transition: DismissTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow)))
        dismissalRoute.transition.isAnimated = false
        
        let dismissalExpectation = expectation(description: "Dismissal expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let presented = self.testableWindow.rootViewController?.presentedViewController as? FooViewController
            XCTAssert(presented?.dismissCalled ?? false)
            dismissalExpectation.fulfill()
        }
        router.navigate(to: dismissalRoute, with: ())
        
        waitForExpectations(timeout: 0.2)
    }

    func testNavigationControllerEmbedding() {
        let transition = RootViewTransition(window: testableWindow)
        let route = Route(builder: NavigationEmbeddingBuilder(), transition: transition)
        transition.isAnimated = false
        let fooBuilder = XibBuildingFactory<FooViewController>()
        router.navigate(to: route, with: [
            try? fooBuilder.build(with: ())
            ].compactMap { $0 })
        
        XCTAssertEqual((root as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((root as? UINavigationController)?.viewControllers.first is FooViewController)
    }
    
    func testSingleNavigationViewEmbedding() {
        let transition = RootViewTransition(window: testableWindow)
        let route = Route(builder: SingleViewNavigationEmbeddingBuilder(builder: XibBuildingFactory<FooViewController>()),
                          transition: transition)
        transition.isAnimated = false
        router.navigate(to: route, with: ())
        
        XCTAssertEqual((root as? UINavigationController)?.viewControllers.count, 1)
        XCTAssert((root as? UINavigationController)?.viewControllers.first is FooViewController)
    }
    
    func testFindingAndUpdatingAlreadyPresentedView() {
        let transition = RootViewTransition(window: testableWindow)
        transition.isAnimated = false
        let route = Route(builder: IntFactory(window: testableWindow), transition: transition)
        router.updateOrNavigate(to: route, with: 1)
        
        XCTAssertEqual((root as? IntViewController)?.value, 1)
        XCTAssertFalse((root as? IntViewController)?.wasUpdated ?? true)
        XCTAssertTrue((root as? IntViewController)?.wasCreated ?? false)
        
        router.updateOrNavigate(to: route, with: 2)
        
        XCTAssertEqual((root as? IntViewController)?.value, 2)
        XCTAssertTrue((root as? IntViewController)?.wasUpdated ?? false)
        XCTAssertFalse((root as? IntViewController)?.wasCreated ?? true)
    }
    
    func testViewCanBeConfiguredPriorToKickingOffTransition() {
        testableWindow.rootViewController = UINavigationController()
        let transition = PushNavigationTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow))
        let route = Route(builder: XibBuildingFactory<FooViewController>(), transition: transition)
        route.prepareForShowTransition = { newView, transition, oldView in
            newView.title = "Foo"
            oldView?.title = "Bar"
        }
        XCTAssertNil(testableWindow.rootViewController?.title)
        
        router.navigate(to: route, with: ())
        
        XCTAssertEqual(testableWindow.rootViewController?.title, "Foo")
        XCTAssertEqual((testableWindow.rootViewController as? UINavigationController)?.viewControllers.first?.title, "Foo")
    }
    
    func testViewCanBeConfiguredPriorToHideTransition() {
        let exp = expectation(description: "NavigationCompletion")
        let popRoute = Route(builder: NonBuilder(),
                             transition: PopNavigationTransition(finder: CurrentlyVisibleViewFinder(rootViewProvider: testableWindow)))
        popRoute.prepareForHideTransition = { view, transition in
            view.title = "Foo"
        }
        popRoute.transition.isAnimated = false
        let navigation = UINavigationController()
        navigation.setViewControllers([FooViewController(),FooViewController()], animated: false)
        let foo = navigation.viewControllers.last
        testableWindow?.rootViewController = navigation
        router.navigate(to: popRoute, with: ()) { result in
            if result {
                XCTAssertEqual((self.root as? UINavigationController)?.viewControllers.count, 1)
                XCTAssertEqual(foo?.title, "Foo")
                exp.fulfill()
            } else {
                XCTFail("failed to perform transition")
            }
        }
        waitForExpectations(timeout: 0.1)
    }
    
    func testTabBarIsBuildable() throws {
        let builder = TabBarEmbeddingBuilder()
        let tabBar = try builder.build(with: [
            XibBuildingFactory<FooViewController>().build(with: ()),
            XibBuildingFactory<BarViewController>().build(with: ())
        ])
        
        XCTAssertEqual(tabBar.viewControllers?.count, 2)
        XCTAssert(tabBar.viewControllers?.first is FooViewController)
        XCTAssert(tabBar.viewControllers?.last is BarViewController)
    }
    
    func testSplitViewIsBuildable() throws {
        let builder = SplitViewBuilder(masterBuilder: XibBuildingFactory<FooViewController>(),
                                       detailBuilder: XibBuildingFactory<BarViewController>())
        let split = try builder.build(with: ((), ()))
        
        XCTAssertEqual(split.viewControllers.count, 2)
        XCTAssert(split.viewControllers.first is FooViewController)
        XCTAssert(split.viewControllers.last is BarViewController)
    }
}
