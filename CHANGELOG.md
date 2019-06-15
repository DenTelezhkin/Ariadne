# Change Log
All notable changes to this project will be documented in this file.

# Next

## [0.4.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.4.0)

* Support for Swift Package Manager in Xcode 11.
* Added preliminary support for UIKit on Mac(Catalyst)
* `View` renamed to `ViewController` to avoid ambiguity with `SwiftUI.View`

## [0.3.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.3.0)

### Added

* `NonTransition` struct, that represents a transition that should not be performed. This is useful for cases when transition cannot be clearly defined, for example for chainable routes.
* `TransitionType.custom` for custom transitions
* `prepareForCustomTransition` closure on `Route` class

### Changed

* `Routable` protocol how has additional `Transition` associated type to define `ViewTransition`
* `Routable` protocol now requires to have a `ViewBuilder` and `ViewTransition` getters. If your route does not need a builder or does not need a transition, you can return `NonBuilder` or `NonTransition` structs.

## [0.2.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.2.0)

* Support for Xcode 10.2 and Swift 5.

## [0.1.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.1.0)

Initial OSS release, yaaaay!
