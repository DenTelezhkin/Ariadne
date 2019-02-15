![Build Status](https://travis-ci.org/DenTelezhkin/Ariadne.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/DenTelezhkin/Ariadne/coverage.svg?branch=master)](http://codecov.io/github/DenTelezhkin/Ariadne?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/Ariadne/badge.svg) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/Ariadne/badge.svg) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

<p align="left">
  <img height="160" src=logo.jpg />
</p>

# Ariadne

> Ariadne's thread, named for the legend of Ariadne, is the solving of a problem with multiple apparent means of proceeding - such as a physical maze, a logic puzzle, or an ethical dilemma - through an exhaustive application of logic to all available routes.

<p align="right">
  <a href="https://en.wikipedia.org/wiki/Ariadne%27s_thread_(logic)">Wikipedia</a>
</p>


Ariadne is an extensible routing framework, built with composition and dependency injection principles in mind. It helps to create transitions and routes, that abstract away view controller building and presentation logic to make it reusable and compact.

## Motivation

UIKit has a routing problem. All view controller presentation and dismissal methods happen in view controller, which a lot of times leads to bloated view controller, because all view controller building, passing of dependencies and transitions also happen there. This makes view controller aware of next view controller dependencies, as well as put him responsible for transition.

This leads to a lot of other kinds of problems, like for example, what if user tapped on a push notification, and content screen needs to be opened with contents of that push notification, and your logic is now duplicated in several places. Or what if you wrote a fancy transition, but now a second screen needs it as well, and you are forced to either copy-paste code, or make a separate transition classes/helper methods.

To solve those problems, some architectures like [VIPER][viper] promote Router to separate entity, but even MVC/MVP/MVVM app cannot normally operate without some form of Router object.

# Example

Let's say, for example, that you need to present user profile inside `UINavigationController`. Usually, in MVC app without any libraries, you would do something like this:

```swift
let storyboard = UIStoryboard(named: "User", bundle: nil)
let userController = storyboard.instantiateViewController(withIdentifier: "UserViewController")
userController.user = user
let navigation = UINavigationController(rootViewController: userController)
present(navigation, animated: true)
```

With Ariadne, this code is no longer tied to current view controller and can look like this:

```swift
let route = Storyboards.User.userViewController.builder.embeddedInNavigation().presentRoute()
router.navigate(to: route, with: user)
```

## Requirements

* iOS 10+
* macOS 10.12+
* tvOS 10+
* watchOS 3+
* Xcode 10 / Swift 4.2 and higher

## Installation

### CocoaPods

```ruby
pod 'Ariadne', '~> 0.1.0'
```

### Carthage

```ruby
github "DenTelezhkin/Ariadne", ~> 0.1
```

## Overview

`Ariadne` architecture fundamentally starts with `ViewBuilder`. Because view controllers are so tightly coupled with their views on iOS, `UIViewController` is considered to be a `View`. Definition of `ViewBuilder` is simple - it builds a `View` out of provided `Context`:

```swift
protocol ViewBuilder {
    associatedtype ViewType: View
    associatedtype Context
    func build(with context: Context) throws -> ViewType
}
```

Out of the box, `Ariadne` provides builders for:

* UINavigationController
* UITabBarController
* UISplitViewController

Second building block of the framework are `ViewTransition` objects, that are needed to perform transition between views. Out of the box, following transitions are supported:

* UINavigationController transitions - push, pop, pop to root
* UIViewController presentations - present, dismiss
* UIWindow root view controller transition to perform switch of the root view controller with animation.

`ViewBuilder` and `ViewTransition` object can be combined together to form a performable `Route`. For example, given `AlertBuilder`, here's how presenting an alert might look like with `Ariadne`:

```swift
let alertRoute = AlertBuilder().presentRoute()
```

Notice how `presentRoute` method is called identically for `AlertBuilder` and any `UIViewController` builders. By leveraging protocol extensions on `ViewBuilder` any transitions and routes can be reused on `ViewBuilder` instance. To see examples of how `ViewBuilder` protocol can be implemented and extended, please refer to [Implementing view builders](Guides/Implementing-view-builders.md) guide.

Last, but not least, `Router` object ties everything together and allows you to actually perform routes:

```swift
router.navigate(to: alertRoute, with: alertModel, completion: { _ in
    // Route has completed
})
```

Router uses `RootViewProvider` to find which view controller is a root one in a view hierarchy. On iOS and tvOS `RootViewProvider` is an interface for `UIWindow` and allows `Router` to get root view controller of view hierarchy. But on other platforms as well as application extensions UIApplication shared window is not accessible, and in that cases `RootViewProvider` may be different, for example in iMessage apps `MSMessagesAppViewController` may play similar role.

`ViewFinder` object traverses view hierarchy starting from root view to find view controller that is currently visible on screen. On iOS and tvOS `Ariadne` provides implementation of `CurrentlyVisibleViewFinder` class, that recursively searches `UIViewController`, `UINavigationController` and `UITabBarController` to find which view controller is currently visible, but on other platforms and in other scenarios you might want to roll with your implementation or subclass of `CurrentlyVisibleViewFinder`, if your view hierarchy contains other view controller containers.

## SwiftGen integration

[SwiftGen][swiftgen] is a powerful code generator, that can be used to set you free from using String-based API, that is cumbersome and error-prone. For example with storyboards, SwiftGen is able to generate code required for instantiating view controllers and makes this code to guarantee on compile-time that storyboard and view controller exist. `Ariadne` can build on top of that, producing a neat syntax for route building, like so:

```swift
let route = Storyboards.User.userViewController.builder.embeddedInNavigation().presentRoute()
```

To find out, how this can be achieved, refer to [SwiftGen integration](Guides/SwiftGen-integration.md).

## Dependency injection

Different applications can have completely different architectures and requirements. To see examples of simple dependency injection see [SwiftGen integration](Guides/SwiftGen-integration.md) and for more advanced dependency injection with dependency containers like [Dip][dip], head to [Advanced dependency injection examples](Guides/Advanced-dependency-injection.md) guide.

## Example project

iOS Example project can be found in Ariadne.xcodeproj and contains:

* Root view controller animated change
* push/pop, present/dismiss
* Peek & Pop
* Custom transition and presentation
* Update currently visible view.

## License

Ariadne is released under an MIT license. See [LICENSE](LICENSE) for more information.

[viper]: https://www.objc.io/issues/13-architecture/viper/
[swiftgen]: https://github.com/SwiftGen/SwiftGen
[dip]: https://github.com/AliSoftware/Dip
