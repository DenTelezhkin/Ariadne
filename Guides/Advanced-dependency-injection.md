## Advanced dependency injection

If your architecture uses [flow controllers](http://merowing.info/2016/01/improve-your-ios-architecture-with-flowcontrollers/) or is more or less standard MVC app, you can use simple dependency injection, examples of which can be found in [SwiftGen integration guide](SwiftGen-integration.md).

On the other hand, if your app is based on MVVM architecture, or any architecture that relies on injecting services and models, here's more advanced example, that does it. This example is based on usage of dependency injection container [Dip][dip], MVVM setup from [ViewModelOwners][view-model-owners], as well as [RxSwift][rxswift] library to handle bindings.


### Setting up dependency container

Lets say you have a dependency injection container setup, in which you register your ViewModel objects, like so:

```
import Dip

let container = DependencyContainer()
container.register { APIServiceImplementation() as APIService }
container.register { [unowned container] in try UserViewModel(apiService: container.resolve()) }
```

If we include this container in Router class, we can then later use it to resolve necessary dependencies.

```swift
public class ApplicationRouter: Ariadne.Router, ReactiveCompatible {

    let container: DependencyContainer

    init(rootProvider: RootViewProvider, container: DependencyContainer) {
        self.container = container
        super.init(rootViewProvider: rootProvider)
    }
}
```

### Configuring `StoryboardBuilder`

Lets slightly change `StoryboardBuilder` from SwiftGen integration example to support `ViewModelOwners` as well as custom configuration:

```swift
import ViewModelOwners

public class StoryboardBuilder<T: UIViewController & NonReusableViewModelOwner>: ViewBuilder
{
    let scene : SceneType<T>
    var configuration: ((T) -> Void)?

    init(scene: SceneType<T>)
    {
        self.scene = scene
    }

    public func build(with context: T.ViewModelProtocol) -> T {
        let view = scene.instantiate()
        view.viewModel = context
        configuration?(view)
        return view
    }

    public func configured(_ configuration: @escaping (T) -> Void) -> Self {
        self.configuration = configuration
        return self
    }
}

extension SceneType where T : NonReusableViewModelOwner {
    var builder: StoryboardBuilder<T> {
        return .init(scene: self)
    }
}
```

### Pouring syntax sugar

Now, the last thing to do is to create a `Binder` object, that allows us to emit routing events with RxSwift:

```swift
import RxCocoa
import ViewModelOwners

extension Reactive where Base: ApplicationRouter {
    public func navigate<T:Routable>() -> Binder<T>
        where T.Builder.ViewType: NonReusableViewModelOwner, T.Builder.Context == T.Builder.ViewType.ViewModelProtocol
    {
        return Binder(base) { router, route in
            guard let viewModel = try? router.container.resolve() as T.Builder.ViewType.ViewModelProtocol else {
                print("❗️ Failed to resolve \(T.Builder.ViewType.ViewModelProtocol.self) while navigating to \(T.Builder.ViewType.self). Please register \(T.Builder.ViewType.ViewModelProtocol.self)")
                return
            }
            return router.navigate(to: route, with: viewModel)
        }
    }
}
```

### Example usage

Lets put this all into action, shall we?

```swift
extension ApplicationRouter {
    public func userDetails() -> StoryboardBuilder<UserViewController> {
        return Storyboards.User.userView.builder.configured { in
            // additional configuration
        }
    }
}

let openUserSignal == ... // PublishRelay that triggers opening of UserDetails screen.
openUserSignal.map { [router] in router.userDetails().pushRoute() }.emit(to: router.rx.navigate()).disposed(by: rx.disposeBag)
```

[dip]: https://github.com/AliSoftware/Dip
[view-model-owners]: https://github.com/krzysztofzablocki/ViewModelOwners
[rxswift]: https://github.com/ReactiveX/RxSwift
