//
//  ViewFactory.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/1/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

open class NavigationControllerEmbeddingViewFactory: ViewBuilder {
    
    var navigationControllerClosure : () -> UINavigationController = { .init() }
    
    public func build(with context: [View]) throws -> UINavigationController {
        let navigation = navigationControllerClosure()
        navigation.viewControllers = context
        return navigation
    }
}

#endif

public class NonBuildableView : View {}

open class NonBuilder : ViewBuilder {
    public func build(with context: ()) throws -> NonBuildableView {
        assertionFailure("NonBuilder should not be asked to build a view")
        return NonBuildableView()
    }
}
