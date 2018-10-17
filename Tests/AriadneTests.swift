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
    func build(with context: String) throws -> T {
        return T(nibName: nil, bundle: nil)
    }
}

class FooViewController: UIViewController {}

class AriadneTests: XCTestCase {
    
    var root: View? {
        return testableWindow?.rootViewController
    }
    
    var testableWindow : UIWindow?

    override func setUp() {
        super.setUp()
        testableWindow = UIWindow(frame: UIScreen.main.bounds)
    }
    
    func testPushTransition() {
        let router = Router()
        let pushRoute = Route(builder: XibBuildingFactory<FooViewController>(),
                              transition: NavigationTransition(type: .push(animated: true),
                                                               finder: CurrentlyVisibleViewFinder(window: testableWindow)))
        testableWindow?.rootViewController = UINavigationController()
        router.navigate(to: pushRoute, with: "foo")
        
        XCTAssertEqual((root as? UINavigationController)?.viewControllers.count, 1)
    }

}
