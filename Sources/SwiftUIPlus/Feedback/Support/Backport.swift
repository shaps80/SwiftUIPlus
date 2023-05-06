import SwiftUI

internal struct Backport<Wrapped> {
    let content: Wrapped
    init(_ content: Wrapped) {
        self.content = content
    }
}

extension Backport where Wrapped == Any {
    init(_ content: Wrapped) {
        self.content = content
    }
}

extension View {
    var backport: Backport<Self> { .init(self) }
}
