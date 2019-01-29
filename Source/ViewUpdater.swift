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

public protocol ViewUpdater : ViewBuilder where ViewType: ContextUpdatable {
    func findUpdatableView(for context: Context) -> ViewType?
}
