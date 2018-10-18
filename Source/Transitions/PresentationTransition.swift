//
//  PresentationTransition.swift
//  Ariadne
//
//  Created by Denys Telezhkin on 10/18/18.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import Foundation

open class PresentationTransition : ViewTransition {
    open var requiresBuiltView: Bool { return true }
    public let finder : ViewFinder
    
    open var isAnimated : Bool  = true
    
    public init(finder: ViewFinder) {
        self.finder = finder
    }
    
    public func perform(with view: View?, completion: ((Bool) -> ())?) {
        guard let view = view else { completion?(false); return }
        guard let visibleView = finder.currentlyVisibleView(startingFrom: nil) else {
            completion?(false); return
        }
        visibleView.present(view, animated: isAnimated) {
            completion?(true)
        }
    }
}
