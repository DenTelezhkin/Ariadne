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
    func findView<T:ViewBuilder>(for builder: T, with context:T.Context) -> View?
}

public protocol Transition {
    func perform(with view: View,
                 on existing: View,
                 completion: ((Bool) -> ())?)
}

open class Route<Builder: ViewBuilder> {
    var finder: ViewFinder
    var builder: Builder
    var transition: Transition
    
    public init(finder: ViewFinder,
                builder: Builder,
                transition: Transition) {
        self.finder = finder
        self.builder = builder
        self.transition = transition
    }
}

open class Router {
    
    public init() {}
    
    open func navigate<T>(to route: Route<T>,
                                with context: T.Context,
                                completion: ((Bool) -> ())? = nil)
    {
        guard let to = try? route.builder.build(with: context) else {
            // Failed to build view
            return
        }
        guard let from = route.finder.findView(for: route.builder, with: context) else {
            // Failed to find required view
            return
        }
        route.transition.perform(with: to, on: from, completion: completion)
    }
}
