![watchOS](https://img.shields.io/badge/watchOS-DE1F51)
![macOS](https://img.shields.io/badge/macOS-EE751F)
![tvOS](https://img.shields.io/badge/tvOS-00B9BB)
![ios](https://img.shields.io/badge/iOS-0C62C7)
[![swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fshaps80%2FSwiftUIPlus%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/shaps80/SwiftUIPlus)

# SwiftUI Plus

Introducing a collection of SwiftUI additions to make your projects easier to build.

> Additionally, I hope this repo also serves as a great resource for _how_ you to implement SwiftUI features 👍

## Sponsor

Building useful libraries like these, takes time away from my family. I build these tools in my spare time because I feel its important to give back to the community. Please consider [Sponsoring](https://github.com/sponsors/shaps80) me as it helps keep me working on useful libraries like these 😬

You can also give me a follow and a 'thanks' anytime.

[![Twitter](https://img.shields.io/badge/Twitter-@shaps-4AC71B)](http://twitter.com/shaps)

## Additions

#### FittingGeometryReader

A `GeometryReader` that auto-sizes itself, enabling you to size your content automatically, while still gaining access to the proxy's values like its runtime size.

#### Scrollable Stacks

- `VScrollStack` – Wraps a `VStack` in a `ScrollView` while still respecting elements like `Spacer`
- `HScrollStack` – Wraps an `HStack` in a `ScrollView` while still respecting elements like `Spacer`

#### TextSlider

A new text-based slider that provides gestural interactions via drag operations, as well as direct keyboard entry for more specific values. In addition it supports a styling API for custom designs.

#### VFlowStack

A vertical line-based stack view that lays out its children horizontally until they no longer fit at which point it begins “wrapping” the children onto a new line.

> Similar to UICollectionViewFlowLayout

####

__Haptics and Feedback__

Supports various familiar animation-inspired APIs for attaching haptics and other feedback (audio, flash, etc) to state changes.

As a convenience the API provides `haptic` focused APIs.

- `withHaptic(.selection) { }`
- `body.haptic(.selection) { }`

However you can also use the `withFeedback` and `feedback` APIs to gain more control and access to other feedback methods. In particular you can combine methods to provide more complex feedback to the user.

```
withFeedback(
    .haptic(.selection)
    .combined(with: 
        .audio(.focusChangeSmall)
    )
)
```

> This example will play a short audio file, while providing haptic feedback (where supported)

Also note, the Feedback Audio APIs provide simplified access to almost all built-in audio files for your convenience.

## Dependencies

This package automatically includes [SwiftBackports](https://github.com/shaps80/SwiftBackports) and [SwiftUIBackports](https://github.com/shaps80/SwiftUIBackports) to provide a richer set of APIs for all SwiftUI clients.

- If you only want SwiftUI additions, you can use the [SwiftUIBackports](https://github.com/shaps80/SwiftUIBackports) package directly.
- If instead you only need the Swift additions, you can use [SwiftBackports](https://github.com/shaps80/SwiftBackports), which also includes support for olders operating systems.

## Installation

You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/shaps80/SwiftUIPlus.git", .upToNextMinor(from: "1.0.0"))`
