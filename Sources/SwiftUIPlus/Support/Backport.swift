import SwiftUI

internal struct Backport<Wrapped> {
    let wrapped: Wrapped
    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }
}

internal extension View {
    var backport: Backport<Self> { .init(self) }
}
