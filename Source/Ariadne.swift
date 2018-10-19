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

public enum TransitionType {
    case hide
    case show
}

public protocol ViewFinder {
    func currentlyVisibleView(startingFrom: View?) -> View?
}

public protocol ViewTransition {
    var isAnimated: Bool { get }
    var transitionType: TransitionType { get }
    var viewFinder: ViewFinder { get }
    
    func perform(with view: View,
                 on visibleView: View?,
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
        guard let visibleView = route.transition.viewFinder.currentlyVisibleView(startingFrom: nil) else {
            completion?(false); return
        }
        switch route.transition.transitionType {
        case .hide:
            route.transition.perform(with: visibleView, on: nil, completion: completion)
        case .show:
            guard let viewToShow = try? route.builder.build(with: context) else {
                completion?(false); return
            }
            route.transition.perform(with: viewToShow, on: visibleView, completion: completion)
        }
    }
}
