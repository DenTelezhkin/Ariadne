//
//  NavigationViewBuilder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/1/18.
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

#if canImport(UIKit)
import UIKit

open class NavigationEmbeddingBuilder: ViewBuilder {
    
    open var navigationControllerBuilder : () -> UINavigationController = { .init() }
    
    public func build(with context: [View]) throws -> UINavigationController {
        let navigation = navigationControllerBuilder()
        navigation.viewControllers = context
        return navigation
    }
}

open class NavigationSingleViewEmbeddingBuilder<T:ViewBuilder> : ViewBuilder {
    public typealias Context = T.Context
    
    public let builder : T
    open var navigationControllerBuilder : () -> UINavigationController = { .init() }
    
    public init(builder: T) {
        self.builder = builder
    }
    
    public func build(with context: Context) throws -> UINavigationController {
        let view = try builder.build(with: context)
        let navigation = navigationControllerBuilder()
        navigation.viewControllers = [view]
        return navigation
    }
}

extension ViewBuilder {
    public func embeddedInNavigation(navigationBuilder: @escaping () -> UINavigationController = { .init() }) -> NavigationSingleViewEmbeddingBuilder<Self> {
        let builder = NavigationSingleViewEmbeddingBuilder(builder: self)
        builder.navigationControllerBuilder = navigationBuilder
        return builder
    }
}

#endif
