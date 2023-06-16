import SwiftUI

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct FrameChangeModifier: ViewModifier {
    let coordinateSpace: CoordinateSpace
    let handler: (CGRect) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader {
                    Color.clear.preference(
                        key: FramePreferenceKey.self,
                        value: $0.frame(in: coordinateSpace)
                    )
                }
            )
            .onPreferenceChange(FramePreferenceKey.self) {
                guard !$0.isEmpty else { return }
                handler($0)
            }
    }
}

internal extension View {
    func onFrameChange(coordinateSpace: CoordinateSpace = .global, _ handler: @escaping (CGRect) -> Void) -> some View {
        modifier(FrameChangeModifier(coordinateSpace: coordinateSpace, handler: handler))
    }
}
