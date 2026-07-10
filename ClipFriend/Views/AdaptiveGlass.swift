//
//  AdaptiveGlass.swift
//  ClipFriend
//

import SwiftUI

extension View {
    // Note: this file references the real Liquid Glass API (`.glassEffect`), which only exists
    // in the macOS 26 SDK. Building this project requires an Xcode version that ships that SDK -
    // the `#available` check below only gates when the code *runs*, not whether it *compiles*.
    @ViewBuilder
    func adaptiveGlassBackground(cornerRadius: CGFloat = 12) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
        }
    }
}
