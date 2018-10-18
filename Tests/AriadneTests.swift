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
    }
    
    func testPushTransition() {
        let pushRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                              transition: NavigationTransition(type: .push(animated: true),
                                                               finder: CurrentlyVisibleViewFinder(window: testableWindow)))
        testableWindow?.rootViewController = UINavigationController()
        router.navigate(to: pushRoute, with: ())
        
        XCTAssertEqual((root as? UINavigationController)?.viewControllers.count, 1)
    }
    
    func testPopTransition() {
        let exp = expectation(description: "NavigationCompletion")
        let popRoute = Route(builder: NonBuilder(),
                              transition: NavigationTransition(type: .pop(animated: false),
                                                               finder: CurrentlyVisibleViewFinder(window: testableWindow)))
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
        switchRootViewRoute.transition.animationsEnabled = false
        router.navigate(to: switchRootViewRoute, with: ())
        
        XCTAssert(testableWindow.rootViewController is BarViewController)
    }

}
