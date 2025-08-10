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
    case .text(let str, _):
        pasteboard.clearContents()
        pasteboard.setString(str, forType: .string)
    case .image(let image, _):
        // converts it back to an nsImage so it can be pasted
        pasteboard.clearContents()
        if let nsImage = NSImage(data: image) {
            pasteboard.writeObjects([nsImage])
        }
    case .none:
        pasteboard.clearContents()
    }
}
