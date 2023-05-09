import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS 15, macOS 12, *)
public extension TextSliderStyle where Self == BorderedTextSliderStyle {
    static var bordered: Self { .init() }
}

@available(iOS 15, macOS 12, *)
public struct BorderedTextSliderStyle: TextSliderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            TextField("", value: .constant(configuration.bounds.upperBound), format: configuration.format)
                .opacity(0)
            configuration.label
        }
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

@available(iOS 15, macOS 12, *)
struct BorderedStyle_Previews: PreviewProvider {
    struct Demo: View {
        @State private var value: CGFloat = 500
        var body: some View {
            TextSlider(value: $value, in: 200...1500, step: 1)
                .textSliderStyle(.bordered)
                .multilineTextAlignment(.center)
                .monospacedDigit()
                .fixedSize()
        }
    }
    static var previews: some View {
        Demo()
    }
}
#endif
