//
//  Ariadne.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/11/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
public typealias View = UIViewController
#endif

public protocol ViewBuilder {
    associatedtype ViewType : View
    associatedtype Context
    
    func build(with context: Context) throws -> ViewType
}

public protocol ViewFinder {
    func currentlyVisibleView() -> View?
}

public protocol ViewTransition {
    associatedtype Finder: ViewFinder
    
    func perform(with view: View,
                 completion: ((Bool) -> ())?)
}

open class Route<Builder: ViewBuilder, Transition: ViewTransition> {
    var builder: Builder
    var transition: Transition
    
    public init(builder: Builder,
                transition: Transition) {
        self.builder = builder
        self.transition = transition
    }
}

open class Router {
    
    public init() {}
    
    open func navigate<T, U>(to route: Route<T,U>,
                                with context: T.Context,
                                completion: ((Bool) -> ())? = nil)
    {
        guard let to = try? route.builder.build(with: context) else {
            // Failed to build view
            return
        }
        route.transition.perform(with: to, completion: completion)
    }
}
