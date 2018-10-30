//
//  NonBuilder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/30/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

public class NonBuildableView : View {}

open class NonBuilder : ViewBuilder {
    public init() {}
    public func build(with context: ()) throws -> NonBuildableView {
        assertionFailure("NonBuilder should not be asked to build a view")
        return NonBuildableView()
    }
}

