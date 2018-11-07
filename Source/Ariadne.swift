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

public protocol ContextUpdatable {
    associatedtype Context
    
    func update(with context: Context)
}

public protocol ViewUpdater : ViewBuilder where ViewType: ContextUpdatable {
    func findUpdatableView(for context: Context) -> ViewType?
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
    var viewFinder: ViewFinder? { get }
    
    func perform(with view: View,
                 on visibleView: View?,
                 completion: ((Bool) -> ())?)
}

open class Route<Builder: ViewBuilder, Transition: ViewTransition> {
    open var builder: Builder
    open var transition: Transition
    
    open var prepareForHideTransition: ((_ visibleView: View, _ transition: Transition) -> ())?
    open var prepareForShowTransition: ((_ view: Builder.ViewType, _ transition: Transition, _ toView: View?) -> ())?
    
    public init(builder: Builder,
                transition: Transition) {
        self.builder = builder
        self.transition = transition
    }
}

extension ViewBuilder {
    public func navigationPushRoute(isAnimated: Bool = true) -> Route<Self, PushNavigationTransition> {
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
    
    public static func navigationPopRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Route<NonBuilder, PopNavigationTransition>(builder: NonBuilder(), transition: PopNavigationTransition(isAnimated: isAnimated))
    }
    
    public func navigationPopRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Router.navigationPopRoute(isAnimated: isAnimated)
    }
    
    public static func navigationPopToRootRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopToRootNavigationTransition> {
        return Route<NonBuilder, PopToRootNavigationTransition>(builder: NonBuilder(), transition: PopToRootNavigationTransition(isAnimated: isAnimated))
    }
    
    public func navigationPopToRootRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopToRootNavigationTransition> {
        return Router.navigationPopToRootRoute(isAnimated: isAnimated)
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
        guard let visibleView = (route.transition.viewFinder ?? viewFinder).currentlyVisibleView(startingFrom: nil) else {
            completion?(false); return
        }
        switch route.transition.transitionType {
        case .hide:
            route.prepareForHideTransition?(visibleView, route.transition)
            route.transition.perform(with: visibleView, on: nil, completion: completion)
        case .show:
            guard let viewToShow = try? route.builder.build(with: context) else {
                completion?(false); return
            }
            route.prepareForShowTransition?(viewToShow, route.transition, visibleView)
            route.transition.perform(with: viewToShow, on: visibleView, completion: completion)
        }
    }
    
    open func updateOrNavigate<T: ViewUpdater,U>(to route: Route<T, U>,
                                                 with context: T.Context,
                                                 completion: ((T.ViewType?,Bool) -> ())? = nil)
        where T.Context == T.ViewType.Context
    {
        guard let updatableView = route.builder.findUpdatableView(for: context) else {
            navigate(to: route, with: context) { completion?(nil, $0) }
            return
        }
        updatableView.update(with: context)
        completion?(updatableView, true)
    }
}
