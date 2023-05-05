import SwiftUI
import SwiftUIBackports

#if os(iOS) || os(macOS)
@available(iOS 15, macOS 13, *)
internal struct TextSliderField: View {
    private static let defaultFormat: FloatingPointFormatStyle<Double>
    = .number.precision(.fractionLength(0...1))
    private static let logicalWidth: CGFloat = 320

    @State private var adjustedValue: Double
    @State private var previousValue: CGFloat = 0
    @State private var lockedAxis: Axis?
    @FocusState private var focus

    @Binding var value: Double
    var bounds: ClosedRange<Double>
    var step: Double.Stride
    var format: FloatingPointFormatStyle<Double>
    @Binding var phase: TextSlider.Phase

    internal init(value: Binding<Double>, bounds: ClosedRange<Double>, step: Double.Stride, format: FloatingPointFormatStyle<Double>?, phase: Binding<TextSlider.Phase>) {
        _phase = phase
        _adjustedValue = .init(initialValue: value.wrappedValue)
        _value = value
        self.bounds = bounds
        self.step = step
        self.format = format ?? .number.precision(.fractionLength(0...1)).grouping(.never)
    }

    public var body: some View {
        TextField(
            "",
            value: $adjustedValue,
            format: format,
            prompt: Text(value, format: format)
        )
        .focused($focus)
        .overlay {
            if !focus {
                // this prevents the normal TextField interactions, rather we treat the field as a button
                Color.primary.opacity(0.0001)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    switch phase {
                    case .ended:
                        phase = .began
                    case .began:
                        withAnimation {
                            phase = .dragging
                        }
                        previousValue = normalizedValue
                        focus = false
                    case .dragging:
                        if lockedAxis == nil {
                            let x = abs(value.location.x - value.startLocation.x)
                            let y = abs(value.location.y - value.startLocation.y)
                            lockedAxis = x > y ? .horizontal : .vertical
                        }

                        let adjustment: CGFloat = 1
                        let previous: CGFloat
                        let next: CGFloat

                        switch lockedAxis ?? .vertical {
                        case .horizontal:
                            previous = (1 - (value.location.x / Self.logicalWidth)) * adjustment
                            next = (1 - (value.startLocation.x / Self.logicalWidth)) * adjustment
                        case .vertical:
                            previous = value.location.y / Self.logicalWidth * adjustment
                            next = value.startLocation.y / Self.logicalWidth * adjustment
                        }

                        update(previousValue + next - previous)
                    case .editing:
                        break
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        phase = .ended
                        lockedAxis = nil
                    }
                }
                .simultaneously(with: TapGesture(count: 1)
                    .onEnded { _ in
                        guard phase != .dragging else { return }
                        focus = true
                    }
                )
        )
        .onSubmit(submit)
        .onChange(of: adjustedValue) { newValue in
            if phase == .dragging {
                value = newValue
            }
        }
        .onChange(of: focus) { newValue in
            if newValue {
                phase = .editing
            } else {
                submit()
                phase = newValue ? .editing : .ended
            }
        }
        .onChange(of: value) { newValue in
            adjustedValue = newValue
            focus = false
        }
    }

    private func submit() {
        guard value != adjustedValue else { return }
        value = max(min(adjustedValue, bounds.upperBound), bounds.lowerBound)
    }
}

@available(iOS 15, macOS 13, *)
private extension TextSliderField {
    var normalizedValue: CGFloat {
        adjustedValue.map(from: bounds, to: 0...1)
    }

    func update(_ newValue: Double) {
        let boundedValue = newValue.map(from: 0...1, to: bounds)
        let clamped = max(bounds.lowerBound, min(bounds.upperBound, boundedValue))

        if step > 0 {
            let advanced = Double.zero.advanced(by: step)
            value = round((clamped - bounds.lowerBound) / advanced) * advanced + bounds.lowerBound
        } else {
            value = clamped
        }
    }
}

internal extension FloatingPoint {
    func map(from source: ClosedRange<Self>, to destination: ClosedRange<Self>) -> Self {
        let oldRange = source.upperBound - source.lowerBound
        let newRange = destination.upperBound - destination.lowerBound
        return (((self - source.lowerBound) * newRange) / oldRange) + destination.lowerBound
    }
}

internal extension ClosedRange where Bound: FloatingPoint {
    func map(from source: Self, to destination: Self) -> Self {
        let min = lowerBound.map(from: source, to: destination)
        let max = upperBound.map(from: source, to: destination)
        return min...max
    }
}
#endif
