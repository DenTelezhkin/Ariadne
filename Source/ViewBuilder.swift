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

public typealias View = WKInterfaceController
#endif

#if os(iOS) || os(tvOS)
import UIKit
public typealias View = UIViewController
#endif

#if canImport(AppKit)
import AppKit
public typealias View = NSViewController
#endif

public protocol ViewBuilder {
    associatedtype ViewType : View
    associatedtype Context
    
    func build(with context: Context) throws -> ViewType
}

extension ViewBuilder where Context == Void {
    public func build() throws -> ViewType {
        return try build(with: ())
    }
}

public class NonBuildableView : View {}

open class NonBuilder : ViewBuilder {
    public init() {}
    public func build(with context: ()) throws -> NonBuildableView {
        assertionFailure("NonBuilder should not be asked to build a view")
        return NonBuildableView()
    }
}

open class InstanceViewBuilder<T: View> : ViewBuilder {
    
    public let closure: () -> T
    
    public init(_ closure: @escaping () -> T) {
        self.closure = closure
    }
    
    public func build(with context: ()) -> T {
        return closure()
    }
}

#if canImport(UIKit)

#if os(iOS) || os(tvOS)

extension ViewBuilder {
    public func pushRoute(isAnimated: Bool = true) -> Route<Self, PushNavigationTransition> {
        return Route(builder: self, transition: PushNavigationTransition(isAnimated: isAnimated))
    }
    
    public func presentRoute(isAnimated: Bool = true) -> Route<Self, PresentationTransition> {
        return Route(builder: self, transition: PresentationTransition(isAnimated: isAnimated))
    }
    
    public func with<T:ViewTransition>(_ transition: T) -> Route<Self, T> {
        return Route(builder: self, transition: transition)
    }
}

#endif

#endif
