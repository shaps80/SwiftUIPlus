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

#### Containers

Various containers that provide a richer set of customizations than currently provided by SwiftUI itself.

## Dependencies

This package automatically includes [SwiftBackports](https://github.com/shaps80/SwiftBackports) and [SwiftUIBackports](https://github.com/shaps80/SwiftUIBackports) to provide a richer set of APIs for all SwiftUI clients.

- If you only want SwiftUI additions, you can use the [SwiftUIBackports](https://github.com/shaps80/SwiftUIBackports) package directly.
- If instead you only need the Swift additions, you can use [SwiftBackports](https://github.com/shaps80/SwiftBackports), which also includes support for olders operating systems.

## Installation

You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/shaps80/SwiftUIPlus.git", .upToNextMinor(from: "1.0.0"))`
