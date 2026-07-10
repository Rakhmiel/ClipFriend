//
//  AppendtoClipbaord.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/1/25.
//
import Foundation
import SwiftUI

//allows copying of text stored in the app back to the clipboard
func AppendToClipboard(selection: ClipboardFetcher.clipboardData) {
    let pasteboard = NSPasteboard.general
    //clears the device's clipboard
    pasteboard.clearContents()
    //puts the user selection on the device clipboard
    switch selection {
    case .text(let str, _, _):
        pasteboard.clearContents()
        pasteboard.setString(str, forType: .string)
    case .image(let image, _, _):
        // converts it back to an nsImage so it can be pasted
        pasteboard.clearContents()
        if let nsImage = NSImage(data: image) {
            pasteboard.writeObjects([nsImage])
        }
    case .file(let ref, _, _), .video(let ref, _, _):
        // resolves the security-scoped bookmark and writes the original file's URL back to
        // the pasteboard - never re-reads or duplicates the file's bytes
        pasteboard.clearContents()
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: ref.bookmark,
                                  options: .withSecurityScope,
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &isStale) else { return }
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
        pasteboard.writeObjects([url as NSURL])
    case .none:
        pasteboard.clearContents()
    }
}
