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

open class NavigationEmbeddingFactory: ViewBuilder {
    
    var navigationControllerClosure : () -> UINavigationController = { .init() }
    
    public func build(with context: [View]) throws -> UINavigationController {
        let navigation = navigationControllerClosure()
        navigation.viewControllers = context
        return navigation
    }
}

open class SingleViewNavigationEmbeddingFactory<T:ViewBuilder> : ViewBuilder {
    public typealias Context = T.Context
    
    public let builder : T
    var navigationControllerClosure : () -> UINavigationController = { .init() }
    
    public init(builder: T) {
        self.builder = builder
    }
    
    public func build(with context: Context) throws -> UINavigationController {
        let view = try builder.build(with: context)
        let navigation = navigationControllerClosure()
        navigation.viewControllers = [view]
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
