//
//  PresentationTransition.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/18/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

open class BaseAnimatedTransition {
    public var isAnimated: Bool
    public let viewFinder : ViewFinder?
    public init(finder: ViewFinder? = nil, isAnimated: Bool = true) {
        viewFinder = finder
        self.isAnimated = isAnimated
    }
}

#if canImport(UIKit)
import UIKit

open class PresentationTransition : BaseAnimatedTransition, ViewTransition {
    public let transitionType: TransitionType = .show
    
    public func perform(with view: View, on visibleView: View?, completion: ((Bool) -> ())?) {
        guard let visibleView = visibleView else { completion?(false); return }
        visibleView.present(view, animated: isAnimated) {
            completion?(true)
        }
    }
}

open class DismissTransition: BaseAnimatedTransition, ViewTransition {
    public var transitionType: TransitionType = .hide
    
    public func perform(with view: View, on visibleView: View?, completion: ((Bool) -> ())?) {
        view.dismiss(animated: isAnimated) {
            completion?(true)
        }
    }
}

#endif
