# Change Log
All notable changes to this project will be documented in this file.

# Next

## [0.7.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.7.0)

### Added

* Support for Xcode 12 and Swift 5.3

## [0.6.1](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.6.1)

### Added

* Support for Mac Catalyst.

## [0.6.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.6.0)

### Added

* `ReplaceNavigationTransition` to encapsulate `UINavigationController.setViewControllers(_:animated:)` method call.
* `PopNavigationTransition` `popToFirstInstanceOf` and `popToLastInstanceOf` behaviors for calling `popToViewController(_:animated:)` method on found navigation controller.
* `SplitViewCurrentlyVisibleViewFinder`, a subclass of `CurrentlyVisibleViewFinder`, that allows to prioritize either master or detail view controller when searching for currently visible view controller.

### Changed

* `PopNavigationTransition` now supports both pop and pop to root transitions.

### Deprecated

* `PopToRootNavigationTransition`, it's functionality is moved to `PopNavigationTransition` with .popToRoot kind.

## [0.5.1](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.5.1)

* `NavigationViewBuilder` and `TabBarViewBuilder` now have publicly available initializers.

## [0.5.0](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.5.0)

### Added

* `AnyBuilder` struct, that can be used to erase any `ViewControllerBuilder` type to allow more convenient usage, as well as shorter notation.

### Deprecated

* `ViewBuilder` protocol was deprecated to avoid clashes with SwiftUI `ViewBuilder`. Please use `ViewControllerBuilder` instead.

## [0.4.1](https://github.com/DenTelezhkin/Ariadne/releases/tag/0.4.1)

### Changed

* `BaseTransition.animateAlongsideTransition(with:isAnimated:completion:` method is now open to allow calling and subclassing it in custom transitions.

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
