//
//  CloseWhenUnfocused.swift
//  ClipFriend
//

import SwiftUI
import AppKit

//captures the NSWindow hosting a SwiftUI view, so it can be identified later (e.g. to tell
//whether a "window resigned key" notification belongs to this specific window)
private struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { window = view.window }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    //closes the enclosing window as soon as it stops being the key window - used for the
    //auxiliary Settings/About windows so clicking away dismisses them automatically
    func closeWhenUnfocused() -> some View {
        modifier(CloseWhenUnfocusedModifier())
    }
}

private struct CloseWhenUnfocusedModifier: ViewModifier {
    @State private var hostWindow: NSWindow?

    func body(content: Content) -> some View {
        content
            .background(WindowAccessor(window: $hostWindow))
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { note in
                // closing the captured NSWindow directly (rather than the dismiss() environment
                // action) works the same way regardless of which scene type hosts this view
                guard let resignedWindow = note.object as? NSWindow, resignedWindow == hostWindow else { return }
                resignedWindow.close()
            }
    }
}
