//
//  ViewFactory.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/1/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

open class NavigationControllerEmbeddingViewFactory<T:View>: ViewBuilder {
    
    public func build(with context: T) throws -> UINavigationController {
        return UINavigationController(rootViewController: context)
    }
}

#endif

public class NonBuildableView : View {}

open class NonBuilder : ViewBuilder {
    public func build(with context: ()) throws -> NonBuildableView {
        assertionFailure("NonBuilder should not be asked to build a view")
        return NonBuildableView()
    }
}
