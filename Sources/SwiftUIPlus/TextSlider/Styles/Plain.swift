import SwiftUI

@available(iOS 15, macOS 13, tvOS 15, watchOS 8, *)
public extension TextSliderStyle where Self == PlainTextSliderStyle {
    static var plain: Self { .init() }
}

@available(iOS 15, macOS 13, tvOS 15, watchOS 8, *)
public struct PlainTextSliderStyle: TextSliderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
