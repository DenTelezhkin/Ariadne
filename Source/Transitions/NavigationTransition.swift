//
//  NavigationTransition.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/11/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

open class NavigationTransition: ViewTransition {
    
    public enum TransitionType {
        case push
        case pop
    }
    
    public let type: TransitionType
    public let finder: ViewFinder
    public var isAnimated: Bool = true
    
    public var requiresBuiltView: Bool {
        switch type {
        case .push: return true
        case .pop: return false
        }
    }
    
    init(type: TransitionType = .push, finder: ViewFinder) {
        self.type = type
        self.finder = finder
    }
    
    public func perform(with view: View?, completion: ((Bool) -> ())?) {
        guard let visibleView = finder.currentlyVisibleView(startingFrom: nil) else {
            completion?(false)
            return
        }
        guard let navigation = (visibleView as? UINavigationController) ?? visibleView.navigationController else {
            completion?(false)
            return
        }
        switch type {
        case .push:
            if let view = view {
                navigation.pushViewController(view, animated: isAnimated)
                completion?(true)
            } else {
                completion?(false)
            }
        case .pop:
            navigation.popViewController(animated: isAnimated)
            completion?(true)
        }
    }
}
