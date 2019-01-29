//
//  Route.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 1/29/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import Foundation

open class Route<Builder: ViewBuilder, Transition: ViewTransition>: Routable {
    open var builder: Builder
    open var transition: Transition
    
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

open class UpdatingRoute<Builder: ViewUpdater, Transition: ViewTransition> : Route<Builder, Transition>
    where Builder.Context == Builder.ViewType.Context
{
    open override func perform(withViewFinder viewFinder: ViewFinder, context: Builder.Context, completion: ((Bool) -> ())?) {
        guard let updatableView = builder.findUpdatableView(for: context) else {
            super.perform(withViewFinder: viewFinder,
                          context: context,
                          completion: completion)
            return
        }
        updatableView.update(with: context)
        completion?(true)
    }
}

open class ChainableRoute<T: Routable, U: Routable>: Routable {
    public typealias Builder = T.Builder
    let headRoute: T
    let tailRoute: U
    let tailContext: U.Builder.Context
    
    init(headRoute: T, tailRoute: U, tailContext: U.Builder.Context) {
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
    func chained<T: Routable>(with chainedRoute: T, context: T.Builder.Context) -> ChainableRoute<Self, T> {
        return ChainableRoute(headRoute: self, tailRoute: chainedRoute, tailContext: context)
    }
}
