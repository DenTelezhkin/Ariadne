//
//  ViewBuilder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 1/29/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
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
