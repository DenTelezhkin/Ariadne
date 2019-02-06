//
//  Buildable.swift
//  iOS Example
//
//  Created by Denys Telezhkin on 2/6/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import Ariadne

protocol Buildable {
    associatedtype Context
    
    func update(with context: Context)
}

class StoryboardBuilder<T: UIViewController & Buildable>: ViewBuilder {
    
    let scene : SceneType<T>
    
    init(scene: SceneType<T>) {
        self.scene = scene
    }
    
    func build(with context: T.Context) throws -> T {
        let view = scene.instantiate()
        view.update(with: context)
        return view
    }
}

extension SceneType where T : Buildable {
    var builder: StoryboardBuilder<T> {
        return StoryboardBuilder(scene: self)
    }
}
