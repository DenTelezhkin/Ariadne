This guide gives several examples of how `ViewBuilder` objects may be implemented, as well as extended.

## Constructing `ViewBuilder`

Lets start with very common example of UI - showing alerts using UIAlertController. While being very easy to setup with a few lines of code, default setup for `UIAlertController` lacks dependency injection and is tricky to test. Which is why test for this example would be to not only show how `UIAlertController` can be built with `Ariadne`, but also to become testable and reusable.

To do that, lets start decompositing alert's logic by implementing simple model for `UIAlertAction`:

```swift
class AlertActionModel {
    var isPreferredAction : Bool = false
    let title : String?
    let style : UIAlertAction.Style
    let handler : ((UIAlertAction) -> ())?

    init(title: String? = nil, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> ())? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
```

Next, lets define similar model for `UIAlertController`.

```swift
class AlertModel {
    let title: String?
    let message: String?
    let style: UIAlertController.Style

    var actions: [AlertActionModel] = []

    init(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert) {
        self.title = title
        self.message = message
        self.style = style
    }
}
```

> Note that, to simplify example, not all functionality of `UIAlertController` is supported - such as adding a textfield with configuration handler, but this can easily be added.

Ok, so now when we have models for `UIAlertAction` and `UIAlertController`, we can implement our `AlertBuilder` to build instances of them:

```swift
struct AlertBuilder: ViewBuilder {
    func build(with context: AlertModel) -> UIAlertController {
        let alert = UIAlertController(title: context.title, message: context.message, preferredStyle: context.style)
        for action in context.actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style, handler: action.handler)
            alert.addAction(alertAction)
            if action.isPreferredAction, alert.preferredAction == nil {
                alert.preferredAction = alertAction
            }
        }
        return alert
    }
}
```

On this stage, we are ready to finally use our abstractions. Let's imagine user of the app tapped a button to leave some screen - for example in a game, and you want to warn him, that if he leaves, his progress wont be saved. Here's how we might show this alert to the user:

```swift
let alert = AlertModel(title: "Are you sure you want to leave?", message: "Any unsaved progress will be lost!")
alert.actions.append(.init(title: "No", style: .cancel))
alert.actions.append(.init(title: "Leave", style: .destructive, handler: { [unowned router] _ in
    router.navigate(to: Router.popToRootRoute())
}))
router.navigate(to: AlertBuilder().presentRoute(), with: alert)
```

> Code looks very similar to direct `UIAlertController` initialization, however there are several key differences. First of all, models for alert and actions are completely testable without creating actual controller. Secondly, alert presentation logic is actually completely separated from current view controller, and those models can be created in any environment, like view model in MVVM or presenter in MVP. Last but not least, models coupling with actual UI is not very tight, so in future versions of your app replacing `UIAlertController` with custom built control will be much easier, since actual `UIAlertController` and `UIAlertAction` creation happens in `AlertBuilder` which can be easily replaced.

## Extending `ViewBuilder`

Now, let's imagine we are working on an iPad app, that sometimes requires alerts and pickers to be shown in popover. Lets extend `ViewBuilder` protocol to achieve this:

```swift
extension ViewBuilder {
    func popoverRoute(from sourceView: UIView,
                           permittedArrowDirections : UIPopoverArrowDirection = .up) -> Route<Self, PresentationTransition> {
        let route = presentRoute()
        route.prepareForShowTransition = { view, _, _ in
            view.modalPresentationStyle = .popover
            view.popoverPresentationController?.sourceView = sourceView
            view.popoverPresentationController?.sourceRect = sourceView.bounds
            view.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        }
        return route
    }
}
```

Once this is done, we can actually replace our presentation code with popover presentation code easily:

```swift
router.navigate(to: AlertBuilder().popoverRoute(from: button), with: alert)
```

By leveraging protocol extensions and extending `ViewBuilder` instead of `AlertBuilder` directly we achieved ability to reuse popover presentations for any builders. For example, if some picker requires popover presentation, we can just call it like so:

```swift
router.navigate(to: PickerBuilder().popoverRoute(from: button), with: pickerConfiguration)
```
