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
    func currentlyVisibleView(startingFrom: View?) -> View?
}

public protocol ViewTransition {
    var requiresBuiltView : Bool { get }
    
    func perform(with view: View?,
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
        if route.transition.requiresBuiltView {
            if let destination = try? route.builder.build(with: context) {
                route.transition.perform(with: destination, completion: completion)
            } else {
                completion?(false)
            }
        } else {
            route.transition.perform(with: nil, completion: completion)
        }
    }
}
