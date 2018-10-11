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
