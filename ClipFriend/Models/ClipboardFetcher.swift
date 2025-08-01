//
//  ClipboardFetcher.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 7/31/25.
//

import Foundation
import SwiftUI
import AppKit

//this retrieves the data on the clipboard
class ClipboardFetcher: ObservableObject {
    //this is so the program can handle data other than text
    enum clipboardData: Identifiable {
        var id: Int { UUID().hashValue }
        case text(String)
        case image(NSImage)
        case none
    }
    var newString: String = ""
    var newObject: NSImage?
    
    @Published var clipboard: [clipboardData] = []
    //this retrieves whatever is on the clipboard
    func retrieveClipboard() {
        let pasteboard = NSPasteboard.general
        //checks if it is text and checks if its already stored
        if let string = pasteboard.string(forType: .string) {
            if newString == string {
                return
            }
            else
            {
                newString = string
                clipboard.append(.text(string))
                print(string)
                print("String appended")
                return
            }
        }
        //checks if it is an image and checks if its already stored
        if let image = NSImage(pasteboard: pasteboard) {
            if newObject == image {
                return
            }
            else
            {
                clipboard.append(.image(image))
                print("Image appended")
                return
            }
        }
    }
    func history() -> [clipboardData] {
        return clipboard
    }
    //clears the clipboard and the clipboard of the device
    func clear() {
        clipboard.removeAll()
        NSPasteboard.general.clearContents()
    }
}
