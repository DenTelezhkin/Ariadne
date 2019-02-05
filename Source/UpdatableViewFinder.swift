//
//  ViewUpdater.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 1/29/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

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
