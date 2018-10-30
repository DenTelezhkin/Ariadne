//
//  NavigationViewBuilder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/1/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

open class NavigationEmbeddingBuilder: ViewBuilder {
    
    open var navigationControllerBuilder : () -> UINavigationController = { .init() }
    
    public func build(with context: [View]) throws -> UINavigationController {
        let navigation = navigationControllerBuilder()
        navigation.viewControllers = context
        return navigation
    }
}

open class NavigationSingleViewEmbeddingBuilder<T:ViewBuilder> : ViewBuilder {
    public typealias Context = T.Context
    
    public let builder : T
    open var navigationControllerBuilder : () -> UINavigationController = { .init() }
    
    public init(builder: T) {
        self.builder = builder
    }
    
    public func build(with context: Context) throws -> UINavigationController {
        let view = try builder.build(with: context)
        let navigation = navigationControllerBuilder()
        navigation.viewControllers = [view]
        return navigation
    }
}

#endif
