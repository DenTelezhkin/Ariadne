//
//  SplitViewBuilder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/30/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

open class SplitViewBuilder<MasterBuilder:ViewBuilder,DetailBuilder:ViewBuilder>: ViewBuilder {
    open var splitViewControllerBuilder: () -> UISplitViewController = { .init() }
    
    public let masterBuilder: MasterBuilder
    public let detailBuilder: DetailBuilder
    
    public init(masterBuilder: MasterBuilder, detailBuilder: DetailBuilder) {
        self.masterBuilder = masterBuilder
        self.detailBuilder = detailBuilder
    }
    
    public func build(with context: (MasterBuilder.Context, DetailBuilder.Context)) throws -> UISplitViewController {
        let splitView = splitViewControllerBuilder()
        let master = try masterBuilder.build(with: (context.0))
        let detail = try detailBuilder.build(with: (context.1))
        splitView.viewControllers = [master,detail]
        return splitView
    }
}
#endif
