//
//  ViewBuilder.swift
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
#if os(watchOS)
import WatchKit
/// On watchOS, `WKInterfaceController` is considered to be a View, that can participate in navigation and routing.
public typealias ViewController = WKInterfaceController
#endif

#if canImport(UIKit) && !os(watchOS)
import UIKit
/// On iOS and tvOS, `UIViewController` is considered to be a View, that can participate in navigation and routing.
public typealias ViewController = UIViewController
#endif

#if canImport(AppKit)
import AppKit
/// On macOS, `NSViewController` is considered to be a View, that can participate in navigation and routing.
public typealias ViewController = NSViewController
#endif

/// Type, that is capable of building a `View`, given `Context`.
public protocol ViewBuilder {

    /// Type of `View`, that this `ViewBuilder` can build.
    associatedtype ViewType: ViewController

    /// Argument type, that `ViewBuilder` needs to build a `View`.
    associatedtype Context

    /// Builds a `View` using provided `Context` or throws an error, if building process was not successful
    ///
    /// - Parameter context: Argument, required to build `View`.
    /// - Returns: `View`, that was built using provided `Context` object.
    /// - Throws: Build error, if building process was not successful.
    func build(with context: Context) throws -> ViewType
}

extension ViewBuilder where Context == Void {

    /// Builds a `View`, that does not require `Context`, because it's Context is Void.
    ///
    /// - Returns: `View`, that was built using provided `Context` object.
    /// - Throws: Build error, if building process was not successful.
    public func build() throws -> ViewType {
        return try build(with: ())
    }
}

/// View, that should not be built. Can be used for transitions, that hide currently visible view and do not require a new view to be built. For example - `PopNavigationTransition`, or `DismissTransition`.
open class NonBuildableView: ViewController {}

/// Builder, that is incapable of building a view and asserts when asked to do so. Can be used for transitions, that hide currently visible view and do not require a new view to be built. For example - `PopNavigationTransition`, or `DismissTransition`.
open class NonBuilder: ViewBuilder {

    /// Creates `NonBuilder` instance
    public init() {}

    /// This method is not expected to be called and asserts on attempt to call it.
    ///
    /// - Parameter context: empty tuple, `NonBuilder` does not require a `Context`.
    /// - Returns: `NonBuildableView` instance
    open func build(with context: ()) -> NonBuildableView {
        assertionFailure("NonBuilder should not be asked to build a view")
        return NonBuildableView()
    }
}

/// Class, that can be used to build a `View` using provided closure.
open class InstanceViewBuilder<T: ViewController> : ViewBuilder {

    /// Builds a `View`.
    public let closure: () -> T

    /// Creates `InstanceViewBuilder` object with provided closure.
    ///
    /// - Parameter closure: builds instance of a `View`, when called.
    public init(_ closure: @escaping () -> T) {
        self.closure = closure
    }

    /// Builds instance of a `View`.
    ///
    /// - Parameter context: empty tuple, this builder does not require arguments.
    /// - Returns: built view.
    open func build(with context: ()) -> T {
        return closure()
    }
}

#if canImport(UIKit)

#if os(iOS) || os(tvOS)

extension ViewBuilder {

    /// Creates a route, that uses current builder, creates a view, and pushes it onto current navigation stack.
    ///
    /// - Parameter isAnimated: should the navigation push be animated.
    /// - Returns: Route to view built by current builder, that will be pushed onto current navigation stack.
    public func pushRoute(isAnimated: Bool = true) -> Route<Self, PushNavigationTransition> {
        return Route(builder: self, transition: PushNavigationTransition(isAnimated: isAnimated))
    }

    /// Creates a route, that uses current builder, creates a view, and presents it on top of currently visible view.
    ///
    /// - Parameter isAnimated: should the presentation be animated.
    /// - Returns: Route to view built by current builder, that will be presented on top of currently visible view.
    public func presentRoute(isAnimated: Bool = true) -> Route<Self, PresentationTransition> {
        return Route(builder: self, transition: PresentationTransition(isAnimated: isAnimated))
    }

    /// Combines current builder with provided `transition` to create a Route, containing them both.
    ///
    /// - Parameter transition: transition to be performed when navigating to created route.
    /// - Returns: Route, that combines current builder and `transition`.
    public func with<T: ViewTransition>(_ transition: T) -> Route<Self, T> {
        return Route(builder: self, transition: transition)
    }
}

#endif

#endif
