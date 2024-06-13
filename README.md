# BConnect iOS SDK

## Requirements

You must have [CocoaPods](https://cocoapods.org) installed in order to add the dependency.

The SDK target iOS 11 for compilation, and iOS 16 for features. This means you can add the BConnect dependency to an app that targets older versions, and use its functionality in newer iOS versions only.

You also must have a client ID, given by b.connect, and a deeplink scheme set in your application (it will be use as a callback from web pages during the authorize process). 

## Installation

BConnect is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BConnect'
```

## Usage

You will mainly use three objects:
- `BConnect`. This is the SDK's entry point. You can use it through the `shared` property (singleton) to configure it, request an authorize, and handle the authorization callback.
- `BConnectConfiguration`. This is the data structure containing all the information required for the SDK to function correctly.
- `BConnectButton`. This is the UI component.

### Setup

Before performing any request, BConnect must be setup with some informations. For that, you have to instantiate a `BConnectConfiguration` with your settings, and then call `BConnect.setup(configuration:)` method with it.

```swift
let configuration = BConnectConfiguration(
    clientType: .private,
    scheme: "example",
    clientID: "id",
    scopes: ["openid", "email", "given_name", "family_name", "name", "risk_score"],
)
BConnect.shared.setup(configuration: configuration)
```

Some parameters are not required or have defaults.

You can do this when the application starts, when the user clicks on the button, or at any other time of your choice as long as the configuration is set **before a request**. Otherwise, nothing will happen.

Note that the configuration is not saved. You should setup a configuration **each time the application is restarted**.

### Adding a button

To add a BConnectButton in your view, you can add a *UIView* in your *storyboard* or *xib* and then set `BconnectButton` as *class* in the *Identity Inspector*. 

You can also add it from code by instantiating a `BConnectButton()` and adding it in a subview.

You will have to set constraints for the **height** and the **position** of the button. The **width** will be automatically computed.

Tips: you can set a placeholder in *Intrisic Size* from *Size Inspector* (xib/storyboard) to hide *missing constraint* warning.

#### Style

A selection of styles is available for `BConnectButton`. You can also set a custom style by providing a b.connect image name. In that case, you must add the placeholder image in your assets with the same name.

```swift
// Using a default style
bconnectButton.set(style: .icon)

// Using a custom style
bconnectButton.set(style: .custom(name: "bconnect_largebutton_white_noborder"))
```

#### Action

You will want to add a target in order to listen events the same way you would with a UIButton. Note that `BConnectButton` inherits from `UIButton`.

```swift
bconnectButton.addTarget(self, action: #selector(onTapBConnect), for: .touchUpInside)
```

```swift
@objc
private func onTapBConnect(sender : UIButton) {
    // Authorize
}
```

You can also do it from a stoyboard with an IBAction.

### Requesting an authorize

You can start an authorization flow by calling `BConnect.requestAuthorize(from:completion:)`. The completion closure will give you a `BConnectResult` (enum) : a success with requested informations, an error, or a cancellation by the user.

```swift
BConnect.shared.requestAuthorize(presenting: self) { [weak self] result in
    self?.handleBconnectResult(result)
}
```

This code may be called from a tap on the BConnectButton, for example.

### Handling callback from web session

In order to intercept the authorization callback, you have to call `BConnect.shared.application(open:)` when you application is opened from an URL.

For example, it can be done in the `application(_:open:options:)` method from `AppDelegate`.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if BConnect.shared.application(open: url) {
        return true
    }

    return false
}
```

Or in `scene(_:openURLContexts:)` method if you're using a `SceneDelegate`.

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    _ = BConnect.shared.application(open: url)
}
```

## Troubleshooting

### rsync error during the build process

You can have an error because of Cocoapods. This issue is related to a sandbox violation, and can be caused by the Alamofire framework or AppAuth.

To resolve this issue, you have to disable User Script Sandboxing:
- Navigate to your project settings,
- Go to the ‘Build Settings’ tab,
- Set `No` to `USER SCRIPT SANDBOXING`.
