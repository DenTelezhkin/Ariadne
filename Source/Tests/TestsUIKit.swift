//
//  AriadneTests.swift
//  AriadneTests
//
//  Created by Denys Telezhkin on 10/1/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import Ariadne

#if canImport(UIKit)
import UIKit

class XibBuildingFactory<T: ViewController>: ViewBuilder {
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

class IntViewController: UIViewController, ContextUpdatable {

    var value: Int = 0
    var wasUpdated: Bool = false
    var wasCreated: Bool = true

    init(value: Int) {
        self.value = value
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not expected to be called")
    }

    func update(with context: Int) {
        value = context
        wasCreated = false
        wasUpdated = true
    }
}

class IntFactory: ViewBuilder {

    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func build(with context: Int) throws -> IntViewController {
        return IntViewController(value: context)
    }
}

class Tests_UIKit: XCTestCase {

    var root: ViewController? {
        return testableWindow?.rootViewController
    }

    var rootNavigation: UINavigationController? {
        return testableWindow.rootViewController as? UINavigationController
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    var testableWindow: UIWindow!
    lazy var router = Router(rootViewProvider: self.testableWindow)

    override func setUp() {
        super.setUp()
        testableWindow = UIWindow(frame: UIScreen.main.bounds)
        testableWindow.isHidden = false
        testableWindow.rootViewController = BarViewController()
    }

    func testPushTransition() {
        let pushRoute = XibBuildingFactory<FooViewController>().pushRoute()
        testableWindow?.rootViewController = UINavigationController()
        router.navigate(to: pushRoute)
        XCTAssertEqual(rootNavigation?.viewControllers.count, 1)
    }

    func testPopTransition() {
        let exp = expectation(description: "NavigationCompletion")
        let popRoute = router.popRoute(isAnimated: false)
        let navigation = UINavigationController()
        navigation.setViewControllers([FooViewController(), FooViewController()], animated: false)
        testableWindow?.rootViewController = navigation
        router.navigate(to: popRoute) { result in
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
        let switchRootViewRoute = XibBuildingFactory<FooViewController>()
                .with(RootViewTransition(window: testableWindow, isAnimated: false))
        router.navigate(to: switchRootViewRoute)

        XCTAssert(testableWindow.rootViewController is FooViewController)
    }

    func testPresentationTransition() {
        let presentExpectation = expectation(description: "Presentation expectation")
        let presentationRoute = XibBuildingFactory<FooViewController>().presentRoute(isAnimated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(self.root is BarViewController)
            XCTAssert(self.root?.presentedViewController is FooViewController)
            presentExpectation.fulfill()
        }
        router.navigate(to: presentationRoute)
        waitForExpectations(timeout: 0.2)
    }

    func testDismissTransition() {
        let presentExpectation = expectation(description: "Presentation expectation")
        let presentationRoute = XibBuildingFactory<FooViewController>().presentRoute(isAnimated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(self.root is BarViewController)
            XCTAssert(self.root?.presentedViewController is FooViewController)
            presentExpectation.fulfill()
        }
        router.navigate(to: presentationRoute)
        waitForExpectations(timeout: 0.2)

        let dismissalRoute = router.dismissRoute(isAnimated: false)

        let dismissalExpectation = expectation(description: "Dismissal expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let presented = self.root?.presentedViewController as? FooViewController
            XCTAssert(presented?.dismissCalled ?? false)
            dismissalExpectation.fulfill()
        }
        router.navigate(to: dismissalRoute)

        waitForExpectations(timeout: 0.2)
    }

    func testNavigationControllerEmbedding() {
        let route = Route(builder: NavigationEmbeddingBuilder(),
                          transition: RootViewTransition(window: testableWindow, isAnimated: false))
        let fooBuilder = XibBuildingFactory<FooViewController>()
        router.navigate(to: route, with: [
            try? fooBuilder.build(),
            ].compactMap { $0 })

        XCTAssertEqual(rootNavigation?.viewControllers.count, 1)
        XCTAssert(rootNavigation?.viewControllers.first is FooViewController)
    }

    func testSingleNavigationViewEmbedding() {
        let route = Route(builder: XibBuildingFactory<FooViewController>().embeddedInNavigation(),
                          transition: RootViewTransition(window: testableWindow, isAnimated: false))
        router.navigate(to: route)

        XCTAssertEqual(rootNavigation?.viewControllers.count, 1)
        XCTAssert(rootNavigation?.viewControllers.first is FooViewController)
    }

    func testFindingAndUpdatingAlreadyPresentedView() {
        let route = IntFactory(window: testableWindow)
            .with(RootViewTransition(window: testableWindow, isAnimated: false))
            .asUpdatingRoute(withRootProvider: testableWindow)
        router.navigate(to: route, with: 1)

        XCTAssertEqual((root as? IntViewController)?.value, 1)
        XCTAssertFalse((root as? IntViewController)?.wasUpdated ?? true)
        XCTAssertTrue((root as? IntViewController)?.wasCreated ?? false)

        router.navigate(to: route, with: 2)

        XCTAssertEqual((root as? IntViewController)?.value, 2)
        XCTAssertTrue((root as? IntViewController)?.wasUpdated ?? false)
        XCTAssertFalse((root as? IntViewController)?.wasCreated ?? true)
    }

    func testViewCanBeConfiguredPriorToKickingOffTransition() {
        testableWindow.rootViewController = UINavigationController()
        let route = XibBuildingFactory<FooViewController>().pushRoute()
        route.prepareForShowTransition = { newView, transition, oldView in
            newView.title = "Foo"
            oldView?.title = "Bar"
        }
        XCTAssertNil(root?.title)

        router.navigate(to: route)

        XCTAssertEqual(root?.title, "Foo")
        XCTAssertEqual(rootNavigation?.viewControllers.first?.title, "Foo")
    }

    func testViewCanBeConfiguredPriorToHideTransition() {
        let exp = expectation(description: "NavigationCompletion")
        let popRoute = router.popRoute(isAnimated: false)
        popRoute.prepareForHideTransition = { view, transition in
            view.title = "Foo"
        }
        let navigation = UINavigationController()
        navigation.setViewControllers([FooViewController(), FooViewController()], animated: false)
        let foo = navigation.viewControllers.last
        testableWindow?.rootViewController = navigation
        router.navigate(to: popRoute) { result in
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
            XibBuildingFactory<FooViewController>().build(),
            XibBuildingFactory<BarViewController>().build(),
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

    func testCompositionOfNavigationAndTabBarBuilding() throws {
        let builder = TabBarEmbeddingBuilder()
        let tabBar = try builder.build(with: [
            XibBuildingFactory<FooViewController>().embeddedInNavigation().build(),
            XibBuildingFactory<BarViewController>().embeddedInNavigation().build(),
        ])

        XCTAssert((tabBar.viewControllers?.first as? UINavigationController)?.viewControllers.first is FooViewController)
        XCTAssert((tabBar.viewControllers?.last as? UINavigationController)?.viewControllers.first is BarViewController)
    }

    func testPopToRootNavigationRoute() throws {
        let popRoute = router.popToRootRoute(isAnimated: false)
        let navigation = UINavigationController(rootViewController: FooViewController())
        navigation.pushViewController(BarViewController(), animated: false)
        navigation.pushViewController(BarViewController(), animated: false)
        testableWindow.rootViewController = navigation

        XCTAssertEqual(rootNavigation?.viewControllers.count, 3)

        router.navigate(to: popRoute)

        XCTAssertEqual(rootNavigation?.viewControllers.count, 1)
        XCTAssert(rootNavigation?.viewControllers.first is FooViewController)
    }

    func testPrebuiltViewCanBePresented() {
        let presentExpectation = expectation(description: "Presentation expectation")
        let presentationRoute = InstanceViewBuilder { UINavigationController() }.presentRoute(isAnimated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(self.root is BarViewController)
            XCTAssert(self.root?.presentedViewController is UINavigationController)
            presentExpectation.fulfill()
        }
        router.navigate(to: presentationRoute)
        waitForExpectations(timeout: 0.2)
    }

    func testRoutesCanBeChainable() {
        let pushRoute = XibBuildingFactory<FooViewController>()
            .pushRoute(isAnimated: false)
            .chained(with: XibBuildingFactory<BarViewController>().pushRoute(isAnimated: false))
        testableWindow?.rootViewController = UINavigationController()
        router.navigate(to: pushRoute)
        XCTAssertEqual(rootNavigation?.viewControllers.count, 2)
        XCTAssert(rootNavigation?.viewControllers.first is FooViewController)
        XCTAssert(rootNavigation?.viewControllers.last is BarViewController)
    }
}

#endif
