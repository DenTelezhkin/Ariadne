//
//  CurrentlyVisibleViewFinder.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/17/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
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
#if canImport(UIKit)
import UIKit

extension UIWindow: RootViewProvider {}

open class CurrentlyVisibleViewFinder : ViewFinder {
    
    public let rootViewProvider: RootViewProvider?
    
    public init(rootViewProvider: RootViewProvider?) {
        self.rootViewProvider = rootViewProvider
    }
    
    open func currentlyVisibleView(startingFrom view: View? = nil) -> View? {
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

#endif

open class InstanceViewRootProvider : RootViewProvider {
    
    public let rootView : View
    
    public init(view: View) {
        rootView = view
    }
    
    public var rootViewController: View? {
        return rootView
    }
}
