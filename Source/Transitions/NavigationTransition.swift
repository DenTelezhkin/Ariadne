//
//  NavigationTransition.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/11/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

open class PushNavigationTransition: BaseAnimatedTransition, ViewTransition {
    public let transitionType: TransitionType = .show
    
    public func perform(with view: View, on visibleView: View?, completion: ((Bool) -> ())?) {
        guard let navigation = (visibleView as? UINavigationController) ?? visibleView?.navigationController else {
            completion?(false); return
        }
        navigation.pushViewController(view, animated: isAnimated)
        completion?(true)
    }
}

open class PopNavigationTransition: BaseAnimatedTransition, ViewTransition {
    public var transitionType: TransitionType = .hide
    
    public func perform(with view: View, on visibleView: View?, completion: ((Bool) -> ())?) {
        view.navigationController?.popViewController(animated: isAnimated)
        completion?(true)
    }
}

open class PopToRootNavigationTransition : BaseAnimatedTransition, ViewTransition {
    public var transitionType: TransitionType = .hide
    
    public func perform(with view: View, on visibleView: View?, completion: ((Bool) -> ())?) {
        view.navigationController?.popToRootViewController(animated: isAnimated)
        completion?(true)
    }
}

#endif
