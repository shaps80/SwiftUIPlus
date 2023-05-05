import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS 15, macOS 13, *)
public extension TextSlider {
    /// Creates a new text-based slider
    /// - Parameters:
    ///   - value: A binding to the current value representing this slider's position in the specified bounds
    ///   - bounds: A bounding range used to represent the minimum and maximum values this slider can represent
    ///   - format: A format style  to use when converting between the string the user edits and the underlying value of type.
    init<Value>(value: Binding<Value>, in bounds: ClosedRange<Value> = 0...1, format: FloatingPointFormatStyle<Double>? = nil) where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint {
        self.init(
            value: .init(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Value($0) }
            ),
            bounds: .init(
                uncheckedBounds: (
                    Double(bounds.lowerBound),
                    Double(bounds.upperBound)
                )
            ),
            step: .init(0.1),
            format: format ?? Self.defaultFormat
        )
    }

    /// Creates a new text-based slider
    /// - Parameters:
    ///   - value: A binding to the current value representing this slider's position in the specified bounds
    ///   - bounds: A bounding range used to represent the minimum and maximum values this slider can represent
    ///   - format: A format style  to use when converting between the string the user edits and the underlying value of type.
    init<Value>(value: Binding<Value>, in bounds: ClosedRange<Value> = 0...1, format: FloatingPointFormatStyle<Double>? = nil) where Value: BinaryInteger, Value.Stride: BinaryFloatingPoint {
        self.init(
            value: .init(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Value($0) }
            ),
            bounds: .init(
                uncheckedBounds: (
                    Double(bounds.lowerBound),
                    Double(bounds.upperBound)
                )
            ),
            step: .init(0.1),
            format: format ?? Self.defaultFormat
        )
    }

    /// Creates a new text-based slider
    /// - Parameters:
    ///   - value: A binding to the current value representing this slider's position in the specified bounds
    ///   - bounds: A bounding range used to represent the minimum and maximum values this slider can represent
    ///   - step: A value representing the increment/decrement value used when adjusting this slider's value
    ///   - format: A format style  to use when converting between the string the user edits and the underlying value of type.
    init<Value>(value: Binding<Value>, in bounds: ClosedRange<Value>, step: Value.Stride = 1, format: FloatingPointFormatStyle<Double>? = nil) where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint {
        self.init(
            value: .init(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Value($0) }
            ),
            bounds: .init(
                uncheckedBounds: (
                    Double(bounds.lowerBound),
                    Double(bounds.upperBound)
                )
            ),
            step: .init(step),
            format: format ?? Self.defaultFormat
        )
    }

    /// Creates a new text-based slider
    /// - Parameters:
    ///   - value: A binding to the current value representing this slider's position in the specified bounds
    ///   - bounds: A bounding range used to represent the minimum and maximum values this slider can represent
    ///   - step: A value representing the increment/decrement value used when adjusting this slider's value
    ///   - format: A format style  to use when converting between the string the user edits and the underlying value of type.
    init<Value>(value: Binding<Value>, in bounds: ClosedRange<Value>, step: Value.Stride = 1, format: FloatingPointFormatStyle<Double>? = nil) where Value: BinaryInteger, Value.Stride: BinaryFloatingPoint {
        self.init(
            value: .init(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Value($0) }
            ),
            bounds: .init(
                uncheckedBounds: (
                    Double(bounds.lowerBound),
                    Double(bounds.upperBound)
                )
            ),
            step: .init(step),
            format: format ?? Self.defaultFormat
        )
    }
}

/// Represents a textual slider that supports drag operations in both horizontal and vertical
/// directions. It also supports keyboard entry, a bounding range and stepped values.
/// You can also provide custom styling via the associated modifier.
///
///     TextSlider(value: $value, in: 0...1, step: 0.1, format: .number.precision(.fractionLength(0...1)))
///         .font(.footnote.weight(.medium))
///         .keyboardType(.numberPad)
///         .textSliderStyle(.bordered)
///
@available(iOS 15, macOS 13, *)
public struct TextSlider: View {
    private static let defaultFormat: FloatingPointFormatStyle<Double>
    = .number.precision(.fractionLength(0...1))

    /// Represents the current phase the slider is in
    public enum Phase: Equatable {
        /// An edit operation has begun
        case began
        /// The field is being edited via keyboard
        case editing
        /// The field is being edited via a drag gesture
        case dragging
        /// An edit operation has ended
        case ended
    }

    @Environment(\.textSliderStyle) private var style
    @State private var phase: Phase = .ended

    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double.Stride
    let format: FloatingPointFormatStyle<Double>

    public var body: some View {
        AnyView(
            style.makeBody(
                configuration: .init(
                    _value: $value,
                    _phase: $phase,
                    bounds: bounds,
                    step: step,
                    format: format
                )
            )
        )
        #if os(iOS) || os(tvOS)
        .keyboardType(step < 1 ? .decimalPad : .numberPad)
        #endif
    }
}
#endif
