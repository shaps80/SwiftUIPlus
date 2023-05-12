import SwiftUI

public struct PresentationStyle {
    fileprivate enum Style {
        case sheet
        case fullScreenCover
    }

    fileprivate let _style: Style
    fileprivate init(_ style: Style) { _style = style }
}

public extension PresentationStyle {
    static var sheet: Self { .init(.sheet) }
    static var fullScreenCover: Self { .init(.fullScreenCover) }
}

/// A view that controls a navigation presentation.
public struct PresentationLink<Label>: View where Label: View {
    @Environment(\.presentationDestinations) private var destinations

    private let value: AnyIdentifiable?
    private let valueType: AnyMetaType
    private let label: Label

    /// Create a new link (button) that will trigger a presentation for the specified value.
    ///
    /// When someone activates the presentation link that this initializer
    /// creates, SwiftUI looks for a nearby
    /// ``View/presentationDestination(for:destination:)`` view modifier
    /// with a `data` input parameter that matches the type of this
    /// initializer's `value` input, with one of the following outcomes:
    ///
    /// - Parameters:
    ///   - title: A string that describes the view that this link presents.
    ///   - value: An optional value to present.
    ///     When the user selects the link, SwiftUI stores a copy of the value.
    ///     Pass a `nil` value to disable the link.
    public init<S: StringProtocol, P: Identifiable>(_ title: S, value: P?) where Label == Text {
        self.value = value.flatMap { .init($0) }
        self.valueType = .init(type: P.self)
        self.label = Text(title)
    }

    /// Create a new link (button) that will trigger a presentation for the specified value.
    ///
    /// When someone activates the presentation link that this initializer
    /// creates, SwiftUI looks for a nearby
    /// ``View/presentationDestination(for:destination:)`` view modifier
    /// with a `data` input parameter that matches the type of this
    /// initializer's `value` input, with one of the following outcomes:
    ///
    /// - Parameters:
    ///   - titleKey: A localized string that describes the view that this link
    ///     presents.
    ///   - value: An optional value to present. When someone
    ///     taps or clicks the link, SwiftUI stores a copy of the value.
    ///     Pass a `nil` value to disable the link.
    public init<P: Identifiable>(_ titleKey: LocalizedStringKey, value: P?) where Label == Text {
        self.value = value.flatMap { .init($0) }
        self.valueType = .init(type: P.self)
        self.label = Text(titleKey)
    }

    /// Create a new link (button) that will trigger a presentation for the specified value.
    ///
    /// When someone activates the presentation link that this initializer
    /// creates, SwiftUI looks for a nearby
    /// ``View/presentationDestination(for:destination:)`` view modifier
    /// with a `data` input parameter that matches the type of this
    /// initializer's `value` input, with one of the following outcomes:
    ///
    /// - Parameters:
    ///   - value: An optional value to present.
    ///     When the user selects the link, SwiftUI stores a copy of the value.
    ///     Pass a `nil` value to disable the link.
    ///   - label: A label that describes the view that this link presents.
    public init<P: Identifiable>(value: P?, @ViewBuilder label: () -> Label) {
        self.value = value.flatMap { .init($0) }
        self.valueType = .init(type: P.self)
        self.label = label()
    }

    private var binding: Binding<AnyIdentifiable?> {
        destinations[valueType]?.binding ?? .constant(nil)
    }

    public var body: some View {
        Button {
            if destinations[valueType] != nil {
                destinations[valueType]?.binding.wrappedValue = value
            } else {
                print("A PresentationLink is presenting a value of type “\(valueType.type)” but there is no matching presentationDestination declaration visible from the location of the link. The link cannot be activated")
            }
        } label: {
            label
        }
        .disabled(value == nil)
    }
}

public extension View {
    /// Associates a destination view with a presented data type for use within
    /// a sheet presentation.
    ///
    /// Add this view modifer to a root view to describe the view to display when presenting
    /// a particular kind of data. Use a `PresentationLink` to present
    /// the data. For example, you can present a `ColorDetail` view for
    /// each presentation of a `Color` instance:
    ///
    ///     NavigationStack {
    ///         List {
    ///             PresentationLink("Mint", value: Color.mint)
    ///             PresentationLink("Pink", value: Color.pink)
    ///             PresentationLink("Teal", value: Color.teal)
    ///         }
    ///         .presentationDestination(for: Color.self) { color in
    ///             ColorDetail(color: color)
    ///         }
    ///         .navigationTitle("Colors")
    ///     }
    ///
    /// You can add more than one sheet destination modifier to the stack
    /// if it needs to present more than one kind of data.
    ///
    /// - Parameters:
    ///   - data: The type of data that this destination matches.
    ///   - style: The preferred presentation style to use. Defaults to `sheet`
    ///   - destination: A view builder that defines a view to present
    ///     when a `PresentationLink` activates  a value of type `data`.
    ///      The closure takes one argument, which is the value
    ///     of the data to present.
    func presentationDestination<D: Identifiable, C: View>(for data: D.Type, style: PresentationStyle = .sheet, @ViewBuilder destination: @escaping (D) -> C) -> some View {
        modifier(
            PresentationModifier(
                ofType: D.self,
                style: style,
                destination: { destination($0 as! D) })
        )
    }
}

private struct PresentationDestinationsEnvironmentKey: EnvironmentKey {
    static var defaultValue: [AnyMetaType: Presentation] = [:]
}

private extension EnvironmentValues {
    var presentationDestinations: [AnyMetaType: Presentation] {
        get { self[PresentationDestinationsEnvironmentKey.self] }
        set {
            var current = self[PresentationDestinationsEnvironmentKey.self]
            newValue.forEach { current[$0] = $1 }
            self[PresentationDestinationsEnvironmentKey.self] = current
        }
    }
}

private struct AnyIdentifiable: Identifiable {
    var id: AnyHashable
    var value: Any
    init<T: Identifiable>(_ value: T) {
        self.id = .init(value.id)
        self.value = value
    }
}

private struct AnyMetaType {
    let type: Any.Type
}

extension AnyMetaType: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type
    }
}

extension AnyMetaType: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
    }
}

private extension Dictionary {
    subscript(_ key: Any.Type) -> Value? where Key == AnyMetaType {
        get { self[.init(type: key)] }
        _modify { yield &self[.init(type: key)] }
    }
}

private struct PresentationModifier: ViewModifier {
    @Environment(\.presentationDestinations) private var destinations
    @State fileprivate var item: AnyIdentifiable?

    let style: PresentationStyle
    let valueType: AnyMetaType
    let destination: (Any) -> AnyView
    var body: Never { fatalError() }

    init<T, Content: View>(ofType type: T.Type, style: PresentationStyle, destination: @escaping (Any) -> Content) {
        self.style = style
        self.destination = { .init(destination($0)) }
        self.valueType = .init(type: type)
    }

    func body(content: Content) -> some View {
        Group {
            switch style._style {
            case .sheet:
                content
                    .sheet(item: $item) { destination($0.value) }
            case .fullScreenCover:
#if os(iOS) || os(tvOS)
                if #available(iOS 14, tvOS 14, *) {
                    content
                        .fullScreenCover(item: $item) { destination($0.value) }
                } else {
                    content
                        .sheet(item: $item) { destination($0.value) }
                }
#else
                content
                    .sheet(item: $item) { destination($0.value) }
#endif
            }
        }
        .environment(\.presentationDestinations, [
            valueType: .init(binding: $item, content: destination)
        ])
    }
}

private struct Presentation {
    var binding: Binding<AnyIdentifiable?>
    var content: (Any) -> AnyView
}
