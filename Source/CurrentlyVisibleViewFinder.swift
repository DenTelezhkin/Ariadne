//
//  CurrentlyVisibleViewFinder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/17/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

open class CurrentlyVisibleViewFinder : ViewFinder {
    
    public let window: UIWindow?
    
    public init(window: UIWindow? = UIApplication.shared.keyWindow) {
        self.window = window
    }
    
    public func currentlyVisibleView() -> View? {
        return currentlyVisibleView(startingFrom: window?.rootViewController)
    }
    
    func currentlyVisibleView(startingFrom view: View?) -> View? {
        guard let view = view else { return nil }
        
        var visibleView: View?
        switch view {
        case let tabBar as UITabBarController:
            visibleView = currentlyVisibleView(startingFrom: tabBar.selectedViewController ?? tabBar.presentedViewController) ?? tabBar
        case let navigation as UINavigationController:
            visibleView = currentlyVisibleView(startingFrom: navigation.visibleViewController) ?? navigation
        default:
            visibleView = currentlyVisibleView(startingFrom: view.presentedViewController) ?? view
        }
        return visibleView ?? view
    }
}
