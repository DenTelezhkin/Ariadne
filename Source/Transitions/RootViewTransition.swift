//
//  RootViewTransition.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/18/18.
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

#if os(iOS) || os(tvOS)
import UIKit

open class RootViewTransition: ViewTransition {
    open var transitionType: TransitionType = .show
    open var viewFinder: ViewFinder? = nil

    public let window: UIWindow
    
    open var duration: TimeInterval = 0.3
    open var animationOptions = UIView.AnimationOptions.transitionCrossDissolve
    open var isAnimated : Bool
    
    public init(window: UIWindow, isAnimated: Bool = true) {
        self.window = window
        self.isAnimated = isAnimated
    }
    
    open func perform(with view: View, on visibleView: View?, completion: ((Bool) -> ())?) {
        if isAnimated {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            UIView.transition(with: window, duration: duration,
                              options: animationOptions,
                              animations: {
                self.window.rootViewController = view
            }, completion: { state in
                UIView.setAnimationsEnabled(oldState)
                completion?(state)
            })
        }
        else {
            window.rootViewController = view
            completion?(true)
        }
    }
}

#endif
