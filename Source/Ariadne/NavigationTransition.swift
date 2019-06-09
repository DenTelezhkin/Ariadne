//
//  NavigationTransition.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/11/18.
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

#if os(iOS) || os(tvOS)

/// Class, that encapsulates UINavigationController.pushViewController(_:animated:) method call as a transition.
open class PushNavigationTransition: BaseTransition, ViewTransition {

    /// Transition type .show.
    public let transitionType: TransitionType = .show

    /// Performs transition by calling `pushViewController(_:animated:)` on `visibleView` navigation controller with `view` argument.
    ///
    /// - Parameters:
    ///   - view: view that is being pushed.
    ///   - visibleView: visible view in navigation controller stack.
    ///   - completion: called once transition has been completed
    open func perform(with view: ViewController?, on visibleView: ViewController?, completion: ((Bool) -> Void)?) {
        guard let view = view else { completion?(false); return }
        guard let navigation = (visibleView as? UINavigationController) ?? visibleView?.navigationController else {
            completion?(false); return
        }
        navigation.pushViewController(view, animated: isAnimated)
        callCompletionBlockForTransitionFrom(visibleView, isAnimated: isAnimated, completion: completion)
    }
}

/// Class, that encapsulates UINavigationController.popViewController(_:animated:) method call as a transition.
open class PopNavigationTransition: BaseTransition, ViewTransition {

    /// Transition type .hide.
    public let transitionType: TransitionType = .hide

    /// Performs transition by calling `popViewController(_:animated:)` on `visibleView` navigation controller.
    ///
    /// - Parameters:
    ///   - view: currently visible view
    ///   - visibleView: currently visible view in view hierarchy
    ///   - completion: called once transition has been completed
    open func perform(with view: ViewController?, on visibleView: ViewController?, completion: ((Bool) -> Void)?) {
        guard let visibleView = visibleView else { completion?(false); return }
        guard let navigation = (visibleView as? UINavigationController) ?? visibleView.navigationController else {
            completion?(false); return
        }
        navigation.popViewController(animated: isAnimated)
        callCompletionBlockForTransitionFrom(visibleView, isAnimated: isAnimated, completion: completion)
    }
}

/// Class, that encapsulates UINavigationController.popToRootViewController(animated:) method call as a transition.
open class PopToRootNavigationTransition: BaseTransition, ViewTransition {

    /// Transition type .hide.
    public let transitionType: TransitionType = .hide

    /// Performs transition by calling `popToRootViewController(animated:)` on `visibleView` navigation controller.
    ///
    /// - Parameters:
    ///   - view: currently visible view
    ///   - visibleView: currently visible view in view hierarchy
    ///   - completion: called once transition has been completed
    open func perform(with view: ViewController?, on visibleView: ViewController?, completion: ((Bool) -> Void)?) {
        guard let visibleView = visibleView else { completion?(false); return }
        guard let navigation = (visibleView as? UINavigationController) ?? visibleView.navigationController else {
            completion?(false); return
        }
        navigation.popToRootViewController(animated: isAnimated)
        callCompletionBlockForTransitionFrom(visibleView, isAnimated: isAnimated, completion: completion)
    }
}

#endif

#endif
