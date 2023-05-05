import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS 15, macOS 13, *)
public extension TextSliderStyle where Self == PlainTextSliderStyle {
    static var plain: Self { .init() }
}

@available(iOS 15, macOS 13, *)
public struct PlainTextSliderStyle: TextSliderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
#endif
