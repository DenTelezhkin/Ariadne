//
//  ViewUpdater.swift
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

public protocol ContextUpdatable {
    associatedtype Context
    
    func update(with context: Context)
}

public protocol UpdatableViewFinder {
    associatedtype ViewType : View
    associatedtype Context
    
    func findUpdatableView(for context: Context) -> ViewType?
}

open class CurrentlyVisibleUpdatableViewFinder<T: View & ContextUpdatable> : UpdatableViewFinder {
    
    public let rootProvider : RootViewProvider
    
    public init(rootProvider: RootViewProvider) {
        self.rootProvider = rootProvider
    }
    
    open func findUpdatableView(for context: T.Context) -> T? {
        return CurrentlyVisibleViewFinder(rootViewProvider: rootProvider).currentlyVisibleView() as? T
    }
}
