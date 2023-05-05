import SwiftUI
import SwiftUIBackports

#if os(iOS) || os(macOS)
@available(iOS 15, macOS 13, *)
public extension TextSliderStyle where Self == BorderedTextSliderStyle {
    static var bordered: Self { .init() }
}

@available(iOS 15, macOS 13, *)
public struct BorderedTextSliderStyle: TextSliderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundStyle(.bar)
            }
            .overlay {
                if configuration.phase == .dragging {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.accentColor)
                }
            }
    }
}
#endif
