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

class FooViewController: UIViewController {}
class BarViewController: UIViewController {}

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
    }
    
    func testPushTransition() {
        let pushRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                              transition: NavigationTransition(type: .push,
                                                               finder: CurrentlyVisibleViewFinder(window: testableWindow)))
        testableWindow?.rootViewController = UINavigationController()
        router.navigate(to: pushRoute, with: ())
        
        XCTAssertEqual((root as? UINavigationController)?.viewControllers.count, 1)
    }
    
    func testPopTransition() {
        let exp = expectation(description: "NavigationCompletion")
        let popRoute = Route(builder: NonBuilder(),
                              transition: NavigationTransition(type: .pop,
                                                               finder: CurrentlyVisibleViewFinder(window: testableWindow)))
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
        testableWindow.rootViewController = FooViewController()
        let switchRootViewRoute = Route(builder: XibBuildingFactory<BarViewController>(), transition: RootViewTransition(window: testableWindow))
        switchRootViewRoute.transition.isAnimated = false
        router.navigate(to: switchRootViewRoute, with: ())
        
        XCTAssert(testableWindow.rootViewController is BarViewController)
    }
    
    func testPresentationTransition() {
        let presentExpectation = expectation(description: "Presentation expectation")
        let presentationRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                                      transition: PresentationTransition(finder: CurrentlyVisibleViewFinder(window: testableWindow)))
        presentationRoute.transition.isAnimated = false
        testableWindow.rootViewController = BarViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssert(self.testableWindow.rootViewController is BarViewController)
            XCTAssert(self.testableWindow.rootViewController?.presentedViewController is FooViewController)
            presentExpectation.fulfill()
        }
        router.navigate(to: presentationRoute, with: ())
        waitForExpectations(timeout: 0.2)
    }

}
