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
