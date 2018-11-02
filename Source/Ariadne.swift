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

open class Router {
    
    public var viewFinder: ViewFinder
    public let rootViewProvider: RootViewProvider
    
    public init(rootViewProvider: RootViewProvider) {
        self.viewFinder = CurrentlyVisibleViewFinder(rootViewProvider: rootViewProvider)
        self.rootViewProvider = rootViewProvider
    }
    
    open func pushNavigationRoute<T:ViewBuilder>(with builder: T, isAnimated: Bool = true) -> Route<T, PushNavigationTransition> {
        return Route(builder: builder, transition: PushNavigationTransition(isAnimated: isAnimated))
    }
    
    open func popNavigationRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Route(builder: NonBuilder(), transition: PopNavigationTransition(isAnimated: isAnimated))
    }
    
    open func presentRoute<T:ViewBuilder>(with builder: T, isAnimated: Bool = true) -> Route<T, PresentationTransition> {
        return Route(builder: builder, transition: PresentationTransition(isAnimated: isAnimated))
    }
    
    open func dismissRoute(isAnimated: Bool = true) -> Route<NonBuilder, DismissTransition> {
        return Route(builder: NonBuilder(), transition: DismissTransition(isAnimated: isAnimated))
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
