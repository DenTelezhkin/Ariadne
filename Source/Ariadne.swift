//
//  Ariadne.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/11/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
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

public protocol ViewFinder {
    func currentlyVisibleView(startingFrom: View?) -> View?
}

public protocol RootViewProvider {
    var rootViewController: View? { get }
}

public protocol Routable {
    associatedtype Builder: ViewBuilder
    
    func perform(withViewFinder: ViewFinder,
                context: Builder.Context,
                completion: ((Bool) -> ())?)
}

open class Router {
    
    public var viewFinder: ViewFinder
    public let rootViewProvider: RootViewProvider
    
    #if os(iOS) || os(tvOS)
    
    public init(rootViewProvider: RootViewProvider) {
        self.viewFinder = CurrentlyVisibleViewFinder(rootViewProvider: rootViewProvider)
        self.rootViewProvider = rootViewProvider
    }
    
    #else
    
    public init(rootViewProvider: RootViewProvider, viewFinder: ViewFinder) {
        self.viewFinder = viewFinder
        self.rootViewProvider = rootViewProvider
    }
    
    #endif
    
    #if os(iOS) || os(tvOS)
    
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
    
    #endif
    
    open func navigate<T: Routable>(to route: T,
                                with context: T.Builder.Context,
                                completion: ((Bool) -> ())? = nil)
    {
        route.perform(withViewFinder: viewFinder, context: context, completion: completion)
    }
    
    open func navigate<T:Routable>(to route: T, completion: ((Bool) -> ())? = nil)
        where T.Builder.Context == Void
    {
        navigate(to: route, with: (), completion: completion)
    }
}
