Integrating with SwiftGen requires two steps - defining how you build views, and implementing a `ViewBuilder` that accepts SwiftGen output.

## Buildable protocol

With simple dependency injection, you might write something like this:

```swift
protocol Buildable {
    associatedtype Context
    func update(with context: Context)
}
```

`Buildable` protocol allows you to pass required argument to `UIViewController` you've just built, and update it accordingly, for example:

```swift
class UserViewController: UIViewController, Buildable {
  func update(with user: User) {
    // update views
  }
}
```

If this simple dependency injection is used, then following `ViewBuilder` can be used for SwiftGen:

```swift
class StoryboardBuilder<T: UIViewController & Buildable>: ViewBuilder {

    let scene : SceneType<T>

    init(scene: SceneType<T>) {
        self.scene = scene
    }

    func build(with context: T.Context) -> T {
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
```

This allows you to write elegant routes like so:

```swift
let switchRootRoute = Storyboards.Main.examplesTableViewController.builder
            .embeddedInNavigation()
            .with(transition)
```

If your application architecture requires more complicated dependency injection, for example for injecting services into your viewModel, please read [Advanced dependency injection guide](Advanced-dependency-injection.md) that contains more complicated example for dependency injection.
