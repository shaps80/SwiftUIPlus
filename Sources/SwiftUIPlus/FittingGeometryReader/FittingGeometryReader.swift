import SwiftBackports
import SwiftUI

/// A geometry reader that automatically sizes its height to 'fit' its content.
/// Particularly useful when you need to understand the runtime size but still
/// want your view to size based on its content.
public struct FittingGeometryReader<Content>: View where Content: View {

    @State private var size: CGSize = .init(width: 10, height: 10)
    private let axis: Axis
    private var content: (GeometryProxy) -> Content

    public init(axis: Axis = .vertical, @ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.axis = axis
        self.content = content
    }

    public var body: some View {
        GeometryReader { geo in
            content(geo)
                .fixedSize(horizontal: axis == .vertical ? false : true, vertical: axis == .horizontal ? true : false)
                .modifier(SizeModifier())
                .onPreferenceChange(SizePreferenceKey.self) { size = $0 }
        }
        .frame(height: axis == .vertical ? size.height : nil)
        .frame(width: axis == .horizontal ? size.width : nil)
    }

}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct SizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: geo.size
                )
            }
        )
    }
}
