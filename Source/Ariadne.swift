//
//  Ariadne.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/11/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

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
    var viewFinder: ViewFinder? { get }
    
    func perform(with view: View,
                 on visibleView: View?,
                 completion: ((Bool) -> ())?)
}

extension ViewBuilder {
    public func pushRoute(isAnimated: Bool = true) -> Route<Self, PushNavigationTransition> {
        return Route(builder: self, transition: PushNavigationTransition(isAnimated: isAnimated))
    }
    
    public func presentRoute(isAnimated: Bool = true) -> Route<Self, PresentationTransition> {
        return Route(builder: self, transition: PresentationTransition(isAnimated: isAnimated))
    }
}

open class Router {
    
    public var viewFinder: ViewFinder
    public let rootViewProvider: RootViewProvider
    
    public init(rootViewProvider: RootViewProvider) {
        self.viewFinder = CurrentlyVisibleViewFinder(rootViewProvider: rootViewProvider)
        self.rootViewProvider = rootViewProvider
    }
    
    public static func popRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Route<NonBuilder, PopNavigationTransition>(builder: NonBuilder(), transition: PopNavigationTransition(isAnimated: isAnimated))
    }
    
    public func popRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Router.popRoute(isAnimated: isAnimated)
    }
    
    public static func popToRootRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopToRootNavigationTransition> {
        return Route<NonBuilder, PopToRootNavigationTransition>(builder: NonBuilder(), transition: PopToRootNavigationTransition(isAnimated: isAnimated))
    }
    
    public func popToRootRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopToRootNavigationTransition> {
        return Router.popToRootRoute(isAnimated: isAnimated)
    }
    
    public static func dismissRoute(isAnimated: Bool = true) -> Route<NonBuilder, DismissTransition> {
        return Route<NonBuilder, DismissTransition>(builder: NonBuilder(), transition: DismissTransition(isAnimated: isAnimated))
    }
    
    public func dismissRoute(isAnimated: Bool = true) -> Route<NonBuilder, DismissTransition> {
        return Router.dismissRoute(isAnimated: isAnimated)
    }
    
    open func navigate<T, U>(to route: Route<T,U>,
                                with context: T.Context,
                                completion: ((Bool) -> ())? = nil)
    {
        route.perform(withViewFinder: viewFinder, context: context, completion: completion)
    }
}
