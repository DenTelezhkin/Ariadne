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
                 completion: ((Bool) -> Void)?)
}

/// Object responsible for performing navigation to concrete routes, as well as keeping references to root view provider and view finder.
open class Router {

    /// Object responsible for finding view on which route should be performed
    open var viewFinder: ViewFinder
    
    /// Object responsible for providing root view of interface hierarchy.
    /// - Note: on iOS and tvOS, commonly, the root provider is UIWindow via UIApplication.shared.keyWindow, however there are scenarios where keyWindow might not be accessible, for example in iMesssage apps and application extensions. In those cases you can use root view controller that is accessible in those context, for example in iMessage extensions this could be `MSMessagesAppViewController`, or view controller presented on top of it.
    /// Also, your app might have several UIWindow objects working in the same time, for example when app is using AirPlay, or if `UIWindow`s are used to present different interfaces modally. In those cases it's recommended to have multiple `Router` objects with different `RootViewProvider`s.
    open var rootViewProvider: RootViewProvider

    #if os(iOS) || os(tvOS)

    /// Creates `Router` with `CurrentlyVisibleViewFinder` object set as a `ViewFinder` instance.
    ///
    /// - Parameter rootViewProvider: provider of the root view of interface
    public init(rootViewProvider: RootViewProvider) {
        self.viewFinder = CurrentlyVisibleViewFinder(rootViewProvider: rootViewProvider)
        self.rootViewProvider = rootViewProvider
    }

    #else

    /// Creates `Router` with specified root view provider and view finder.
    ///
    /// - Parameters:
    ///   - rootViewProvider: provider of the root view of interface
    ///   - viewFinder: object responsible for finding view on which route should be performed
    public init(rootViewProvider: RootViewProvider, viewFinder: ViewFinder) {
        self.viewFinder = viewFinder
        self.rootViewProvider = rootViewProvider
    }

    #endif

    #if os(iOS) || os(tvOS)

    open class func popRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Route<NonBuilder, PopNavigationTransition>(builder: NonBuilder(), transition: PopNavigationTransition(isAnimated: isAnimated))
    }

    open func popRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopNavigationTransition> {
        return Router.popRoute(isAnimated: isAnimated)
    }

    open class func popToRootRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopToRootNavigationTransition> {
        return Route<NonBuilder, PopToRootNavigationTransition>(builder: NonBuilder(), transition: PopToRootNavigationTransition(isAnimated: isAnimated))
    }

    open func popToRootRoute(isAnimated: Bool = true) -> Route<NonBuilder, PopToRootNavigationTransition> {
        return Router.popToRootRoute(isAnimated: isAnimated)
    }

    open class func dismissRoute(isAnimated: Bool = true) -> Route<NonBuilder, DismissTransition> {
        return Route<NonBuilder, DismissTransition>(builder: NonBuilder(), transition: DismissTransition(isAnimated: isAnimated))
    }

    open func dismissRoute(isAnimated: Bool = true) -> Route<NonBuilder, DismissTransition> {
        return Router.dismissRoute(isAnimated: isAnimated)
    }

    #endif

    open func navigate<T: Routable>(to route: T,
                                with context: T.Builder.Context,
                                completion: ((Bool) -> Void)? = nil)
    {
        route.perform(withViewFinder: viewFinder, context: context, completion: completion)
    }

    open func navigate<T: Routable>(to route: T, completion: ((Bool) -> Void)? = nil)
        where T.Builder.Context == Void {
        navigate(to: route, with: (), completion: completion)
    }
}
