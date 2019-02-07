//
//  Route.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 1/29/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public enum TransitionType {
    case hide
    case show
}

public protocol ViewTransition {
    var isAnimated: Bool { get }
    var transitionType: TransitionType { get }
    var viewFinder: ViewFinder? { get }
    
    func perform(with view: View,
                 on visibleView: View?,
                 completion: ((Bool) -> ())?)
}

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

#if os(iOS) || os(tvOS)

extension Route where Builder.ViewType : ContextUpdatable, Builder.ViewType.Context == Builder.Context
{
    public func asUpdatingRoute(withRootProvider rootProvider: RootViewProvider) -> UpdatingRoute<CurrentlyVisibleUpdatableViewFinder<Builder.ViewType>,Builder, Transition> {
        return UpdatingRoute(updatableViewFinder: CurrentlyVisibleUpdatableViewFinder(rootProvider: rootProvider),
                             builder: builder,
                             transition: transition)
    }
}

#endif

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
