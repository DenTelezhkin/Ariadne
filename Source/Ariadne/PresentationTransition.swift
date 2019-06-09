//
//  PresentationTransition.swift
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

#if canImport(UIKit)
import UIKit

#if os(iOS) || os(tvOS)

/// Class, that encapsulates UIViewController.present(_:animated:) method call as a transition.
open class PresentationTransition: BaseTransition, ViewTransition {

    /// Transition type .show
    public let transitionType: TransitionType = .show

    /// Performs transition by calling `present(_:animated:)` on `visibleView` with `view` argument.
    ///
    /// - Parameters:
    ///   - view: view that is being presented.
    ///   - visibleView: visible view, on which presentation will being performed.
    ///   - completion: called once presentation has been completed.
    public func perform(with view: ViewController?, on visibleView: ViewController?, completion: ((Bool) -> Void)?) {
        guard let view = view else { completion?(false); return }
        guard let visibleView = visibleView else { completion?(false); return }
        visibleView.present(view, animated: isAnimated) {
            completion?(true)
        }
    }
}

/// Class, that encapsulates `UIViewController.dismiss(animated:)` method call as transition
open class DismissTransition: BaseTransition, ViewTransition {

    /// Transition type .hide
    public let transitionType: TransitionType = .hide

    /// Performs transition by calling `dismiss(animated:)` on `visibleView`.
    ///
    /// - Parameters:
    ///   - view: unused in dismiss transition
    ///   - visibleView: view that will be dismissed
    ///   - completion: called once dismissal is complete
    public func perform(with view: ViewController?, on visibleView: ViewController?, completion: ((Bool) -> Void)?) {
        guard let visibleView = visibleView else { completion?(false); return }
        visibleView.dismiss(animated: isAnimated) {
            completion?(true)
        }
    }
}

#endif

#endif
