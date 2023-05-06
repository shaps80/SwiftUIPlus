import SwiftUI

/// A vertical line-based stack view that lays out its children horizontally until they no longer fit
/// at which point it begins "wrapping" the children onto a new line.
@available(iOS 16, tvOS 16, macOS 13, watchOS 9, *)
public struct VFlowStack<Content: View>: View {
    let positioning: VFlowPositioning
    let content: Content

    /// Creates a new line-based flow layout
    /// - Parameters:
    ///   - alignment: The alignment affects the anchor point for each child relative to its parent container
    ///   - horizontal: The spacing to use along the horizontal axis, between each child
    ///   - vertical: The spacing to use along the vertical axis, between each line
    public init(alignment: Alignment = .center, horizontal: CGFloat? = nil, vertical: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
        self.positioning = .init(
            horizontal: .init(alignment: alignment.horizontal, spacing: horizontal),
            vertical: .init(alignment: alignment.vertical, spacing: vertical)
        )
        self.content = content()
    }

    /// Creates a new line-based flow layout
    /// - Parameters:
    ///   - alignment: The alignment affects the anchor point for each child relative to its parent container
    ///   - spacing: The spacing to use between each child/line along both axes
    public init(alignment: Alignment = .center, spacing: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
        self.positioning = .init(alignment: alignment, spacing: spacing)
        self.content = content()
    }

    /// Creates a new line-based flow layout
    /// - Parameters:
    ///   - positioning: A positioning value allows you to define the alignment _and_ spacing for each axis independently
    public init(positioning: VFlowPositioning, @ViewBuilder _ content: () -> Content) {
        self.positioning = positioning
        self.content = content()
    }

    public var body: some View {
        VFlowLayout(positioning: positioning) { content }
    }
}

@available(iOS 16, tvOS 16, macOS 13, watchOS 9, *)
struct VFlowLayout: Layout {
    static var layoutProperties: LayoutProperties {
        var props = LayoutProperties()
        props.stackOrientation = .vertical
        return props
    }

    struct Cache {
        struct Line {
            var spacing: CGFloat
            var sizes: [CGSize] = []

            var contentSize: CGSize {
                let width = sizes
                    .map { $0.width }
                    .joined(spacing: spacing)
                let height = sizes
                    .reduce(0, { max($0, $1.height) })
                return CGSize(width: width, height: height)
            }

            func fitting(size: CGSize, proposal: ProposedViewSize, spacing: CGFloat) -> Bool {
                let availableWidth = proposal.replacingUnspecifiedDimensions().width
                return size.width < availableWidth - (contentSize.width + spacing)
            }
        }

        var spacing: CGFloat
        var lines: [Line] = []
        var contentSize: CGSize {
            let width = lines
                .reduce(0, { max($0, $1.contentSize.width) })
            let height = lines
                .map { $0.contentSize.height }
                .joined(spacing: spacing)
            return CGSize(width: width, height: height)
        }
    }

    let positioning: VFlowPositioning

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        cache.lines.removeAll()
        var line: Cache.Line = .init(spacing: positioning.horizontal.spacing)

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            if line.fitting(size: size, proposal: proposal, spacing: positioning.horizontal.spacing) {
                line.sizes.append(size)
            } else {
                cache.lines.append(line)
                line = .init(spacing: positioning.horizontal.spacing)
                line.sizes.append(size)
            }
        }

        // Add the last line, if the last line hasn't been added yet
        if !line.sizes.isEmpty { cache.lines.append(line) }
        return cache.contentSize
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var index: Int = 0
        var minY: CGFloat = 0

        for line in cache.lines {
            var minX: CGFloat = 0
            let lineSize = line.contentSize

            switch positioning.horizontal.alignment {
            case .leading:
                minX = 0
            case .trailing:
                minX = bounds.width - lineSize.width
            default:
                minX = (bounds.width - lineSize.width) / 2
            }

            for size in line.sizes {
                var y: CGFloat = 0

                switch positioning.vertical.alignment {
                case .top:
                    y = 0
                case .bottom:
                    y = line.contentSize.height - size.height
                default:
                    y = (line.contentSize.height - size.height) / 2
                }

                let origin = bounds
                    .offsetBy(dx: minX, dy: minY + y)
                    .origin

                subviews[index].place(at: origin, proposal: proposal)
                minX += size.width + positioning.horizontal.spacing
                index += 1
            }

            minY += lineSize.height + positioning.vertical.spacing
        }
    }

    func makeCache(subviews: Subviews) -> Cache {
        .init(spacing: positioning.vertical.spacing)
    }
}

@available(iOS 16, tvOS 16, macOS 13, watchOS 9, *)
public struct VFlowPositioning {
    public struct Horizontal {
        public var alignment: HorizontalAlignment
        public var spacing: CGFloat
        public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
            self.alignment = alignment
            self.spacing = spacing ?? 10
        }
    }

    public struct Vertical {
        public var alignment: VerticalAlignment
        public var spacing: CGFloat
        public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil) {
            self.alignment = alignment
            self.spacing = spacing ?? 10
        }
    }

    public var horizontal: Horizontal
    public var vertical: Vertical
    public init(horizontal: Horizontal = .init(), vertical: Vertical = .init()) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public init(alignment: Alignment, spacing: CGFloat? = nil) {
        self.init(
            horizontal: .init(alignment: alignment.horizontal, spacing: spacing),
            vertical: .init(alignment: alignment.vertical, spacing: spacing)
        )
    }
}

@available(iOS 16, tvOS 16, macOS 13, watchOS 9, *)
private extension BidirectionalCollection where Element: BinaryFloatingPoint {
    func joined(spacing: Element) -> Element {
        let spaced = map { value in
            return value + spacing
        }.reduce(0, { $0 + $1 })
        // remove spacing for last line
        return spaced - spacing
    }
}

@available(iOS 16, tvOS 16, macOS 13, watchOS 9, *)
struct FlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        VFlowStack(alignment: .leading, spacing: 5) {
            Group {
                Text("Foo")
                Text("Bar")
                Text("Foobar")
                Text("Foo")
                Text("Bar")
                Text("Foobar")
            }
            .padding(4)
            .background(.bar, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .padding()
        .frame(width: 200)
    }
}
