//
//  CurrentlyVisibleViewFinder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/17/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

public protocol RootViewProvider {
    var rootViewController: View? { get }
}
extension UIWindow: RootViewProvider {}

open class CurrentlyVisibleViewFinder : ViewFinder {
    
    public let rootViewProvider: RootViewProvider?
    
    public init(rootViewProvider: RootViewProvider? = UIApplication.shared.keyWindow) {
        self.rootViewProvider = rootViewProvider
    }
    
    public func currentlyVisibleView(startingFrom view: View? = nil) -> View? {
        return _currentlyVisibleView(startingFrom: view ?? rootViewProvider?.rootViewController)
    }
    
    func _currentlyVisibleView(startingFrom view: View?) -> View? {
        guard let view = view else { return nil }
        
        var visibleView: View?
        switch view {
        case let tabBar as UITabBarController:
            visibleView = _currentlyVisibleView(startingFrom: tabBar.selectedViewController ?? tabBar.presentedViewController) ?? tabBar
        case let navigation as UINavigationController:
            visibleView = _currentlyVisibleView(startingFrom: navigation.visibleViewController) ?? navigation
        default:
            visibleView = _currentlyVisibleView(startingFrom: view.presentedViewController) ?? view
        }
        return visibleView ?? view
    }
}
