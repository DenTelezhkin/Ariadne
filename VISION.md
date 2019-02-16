# Vision

This document serves to outline long term goals of `Ariadne` and acts as guidance when prioritizing features and make decisions on project development.

## Platforms support

`Ariadne` aims to support 2 to 3 major releases of following operating systems:

* iOS
* tvOS
* macOS
* watchOS

Currently the support for macOS and watchOS is very limited, most of project focus is placed on iOS and tvOS, but later might be expanded to `macOS` and `watchOS`.

## Language support

Because of generics and associated types being heavily used, there are no plans to support Objective-C. Also, because Swift 5 is already in beta, there are no plans to support Swift 3 / 4.0 / 4.1 as well. `Ariadne` requires Xcode 10 and Swift 4.2 at least.

## Features out of scope

It's tempting to add a lot of functionality to routing, for example observing view controller state, or reacting to transition events. However, I believe that routing framework should be as simple as possible and serve as a foundation for any architecture you might need in your app.

To achieve that, `Ariadne` is intentionally built without dependencies other than `UIKit`/`AppKit`/`WatchKit`. Even if that would require some code when setting up architecture of your app, it gives flexibility to use tools you want to use.

For similar reasons, there are no singleton objects like `Router.shared` to provide easy access to one common routing object. It's very easy to extend `Router` type and provide this accessor, or subclass `Router` and provide your own means for getting `Router` object through multiton, or service locator. So, instead of providing opinionated singleton object, `Ariadne` gives you opportunity to tailor it's usage to your needs.

## Evolving

Routing is a complicated topic. There's no silver bullet or magic solution, that will be ideally working for everyone. That's why, despite of `Ariadne` being battle tested and working solution, it's released as `0.1.0` version as opposed to `1.0.0`. Ultimate goal for this project is to learn, educate and collect best practices to structure routing code, and those practices will evolve over time and change how the project works both internally and externally.
