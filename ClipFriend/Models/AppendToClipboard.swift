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
    case .text(let str):
        pasteboard.clearContents()
        pasteboard.setString(str, forType: .string)
    case .image(let image):
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    case .none:
        pasteboard.clearContents()
    }
}
