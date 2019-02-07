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

open class PushNavigationTransition: BaseAnimatedTransition, ViewTransition {
    public let transitionType: TransitionType = .show

    open func perform(with view: View, on visibleView: View?, completion: ((Bool) -> Void)?) {
        guard let navigation = (visibleView as? UINavigationController) ?? visibleView?.navigationController else {
            completion?(false); return
        }
        navigation.pushViewController(view, animated: isAnimated)
        completion?(true)
    }
}

open class PopNavigationTransition: BaseAnimatedTransition, ViewTransition {
    public let transitionType: TransitionType = .hide

    open func perform(with view: View, on visibleView: View?, completion: ((Bool) -> Void)?) {
        view.navigationController?.popViewController(animated: isAnimated)
        completion?(true)
    }
}

open class PopToRootNavigationTransition: BaseAnimatedTransition, ViewTransition {
    public let transitionType: TransitionType = .hide

    open func perform(with view: View, on visibleView: View?, completion: ((Bool) -> Void)?) {
        view.navigationController?.popToRootViewController(animated: isAnimated)
        completion?(true)
    }
}

#endif

#endif
