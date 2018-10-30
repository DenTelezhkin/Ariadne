//
//  TabBarViewBuilder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/30/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

open class TabBarEmbeddingBuilder: ViewBuilder {
    open var tabBarControllerBuilder: () -> UITabBarController = { .init() }
    
    public func build(with context: [View]) throws -> UITabBarController {
        let tabBar = tabBarControllerBuilder()
        tabBar.viewControllers = context
        return tabBar
    }
}
#endif
