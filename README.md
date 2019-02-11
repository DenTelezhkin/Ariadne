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

[Wikipedia][wiki]

Ariadne is an extensible routing framework, built with composition and dependency injection principles in mind. It helps to create transitions and routes, that abstract away view controller building and presentation logic to make it reusable and compact.

## Motivation

UIKit has a routing problem. All view controller presentation and dismissal methods happen in view controller, which a lot of times leads to bloated view controller, because all view controller building, passing of dependencies and transitions also happen there. This makes view controller aware of next view controller dependencies, as well as put him responsible for transition.

This leads to lot other kinds of problems, like for example, what if user tapped on a push notification, and content screen needs to be opened with contents of that push notification, and your logic is now duplicated in several places. Or what if you wrote a fancy transition, but now a second screen needs it as well, and you are forced to either copy-paste code, or make a separate transition classes/helper methods.

To solve those problems, some architectures like [VIPER][viper] promote Router to separate entity, but even MVC/MVP/MVVM app cannot normally operate without some form of Router object.

# Example

Let's say, for example, that you need to present user profile inside `UINavigationController`. Usually, in MVC app without any libraries, you would do something like this:

```swift
let storyboard = UIStoryboard(named: "User", bundle: nil)
let userController = storyboard.instantiateViewController(withIdentifier: "User")
userController.user = user
let navigation = UINavigationController(rootViewController: userController)
present(navigation, animated: true)
```

With Ariadne, this code no is no longer tied to current view controller and can look like this:

```swift
let route = Storyboards.User.userViewController.builder.embeddedInNavigation().presentRoute()
router.navigate(to: route, with: user)
```


[wiki]: https://en.wikipedia.org/wiki/Ariadne%27s_thread_(logic)
[viper]: https://www.objc.io/issues/13-architecture/viper/
