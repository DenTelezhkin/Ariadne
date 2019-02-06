//
//  Route.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 1/29/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import Foundation

open class Route<Builder: ViewBuilder, Transition: ViewTransition>: Routable {
    public let builder: Builder
    public let transition: Transition
    
    open var prepareForHideTransition: ((_ visibleView: View, _ transition: Transition) -> ())?
    open var prepareForShowTransition: ((_ view: Builder.ViewType, _ transition: Transition, _ toView: View?) -> ())?
    
    public init(builder: Builder,
                transition: Transition) {
        self.builder = builder
        self.transition = transition
    }
    
    open func perform(withViewFinder viewFinder: ViewFinder,
                      context: Builder.Context,
                      completion: ((Bool) -> ())? = nil) {
        guard let visibleView = (transition.viewFinder ?? viewFinder)?.currentlyVisibleView(startingFrom: nil) else {
            completion?(false);
            return
        }
        
        switch transition.transitionType {
        case .hide:
            prepareForHideTransition?(visibleView, transition)
            transition.perform(with: visibleView, on: nil, completion: completion)
        case .show:
            guard let viewToShow = try? builder.build(with: context) else {
                completion?(false); return
            }
            prepareForShowTransition?(viewToShow, transition, visibleView)
            transition.perform(with: viewToShow, on: visibleView, completion: completion)
        }
    }
}

open class UpdatingRoute<Finder: UpdatableViewFinder, Builder: ViewBuilder, Transition: ViewTransition> : Route<Builder, Transition>
    where Builder.ViewType : ContextUpdatable,
        Builder.Context == Builder.ViewType.Context,
        Finder.Context == Builder.Context,
        Finder.ViewType == Builder.ViewType
{
    public let updatableViewFinder : Finder
    
    init(updatableViewFinder: Finder, builder: Builder, transition: Transition) {
        self.updatableViewFinder = updatableViewFinder
        super.init(builder: builder, transition: transition)
    }
    
    open override func perform(withViewFinder viewFinder: ViewFinder, context: Builder.Context, completion: ((Bool) -> ())?) {
        guard let updatableView = updatableViewFinder.findUpdatableView(for: context) else {
            super.perform(withViewFinder: viewFinder,
                          context: context,
                          completion: completion)
            return
        }
        updatableView.update(with: context)
        completion?(true)
    }
}

extension Route where Builder.ViewType : ContextUpdatable, Builder.ViewType.Context == Builder.Context
{
    public func asUpdatingRoute(withRootProvider rootProvider: RootViewProvider) -> UpdatingRoute<CurrentlyVisibleUpdatableViewFinder<Builder.ViewType>,Builder, Transition> {
        return UpdatingRoute(updatableViewFinder: CurrentlyVisibleUpdatableViewFinder(rootProvider: rootProvider),
                             builder: builder,
                             transition: transition)
    }
}

open class ChainableRoute<T: Routable, U: Routable>: Routable {
    public typealias Builder = T.Builder
    public let headRoute: T
    public let tailRoute: U
    public let tailContext: U.Builder.Context
    
    public init(headRoute: T, tailRoute: U, tailContext: U.Builder.Context) {
        self.headRoute = headRoute
        self.tailRoute = tailRoute
        self.tailContext = tailContext
    }
    
    open func perform(withViewFinder viewFinder: ViewFinder, context: T.Builder.Context, completion: ((Bool) -> ())?) {
        headRoute.perform(withViewFinder: viewFinder, context: context) { [weak self] completedHead in
            guard let self = self else {
                completion?(false)
                return
            }
            self.tailRoute.perform(withViewFinder: viewFinder, context: self.tailContext, completion: { completedTail in
                completion?(completedHead && completedTail)
            })
        }
    }
}

extension Routable {
    public func chained<T: Routable>(with chainedRoute: T, context: T.Builder.Context) -> ChainableRoute<Self, T> {
        return ChainableRoute(headRoute: self, tailRoute: chainedRoute, tailContext: context)
    }
    
    public func chained<T:Routable>(with chainedRoute: T) -> ChainableRoute<Self, T>
        where T.Builder.Context == Void
    {
        return chained(with: chainedRoute, context: ())
    }
}
