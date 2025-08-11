//
//  ClipboardViewModel.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 7/31/25.
//

import Foundation
import SwiftUI
import AppKit

class ClipboardViewModel: ObservableObject {
    //to not type the same code again it just reuses the enum object from ClipboardFetcher
    @Published var history: [ClipboardFetcher.clipboardData] = []
    let refresher = ClipboardFetcher()
    //this refreshes the clipboard data when called
    func refresh() {
        refresher.retrieveClipboard()
        let newEntries = refresher.clipboard.filter { entry in
            !history.contains(where: { existing in
                switch (entry, existing) {
                case (.text(let s1, _), .text(let s2, _)):
                    return s1 == s2
                case (.image(let img1, _), .image(let img2, _)):
                    // Compare image data to detect duplicates
                    return img1 == img2
                default:
                    return false
                }
            })
        }
        history.insert(contentsOf: newEntries, at: 0)
    }
    func updateClipboard(selection: ClipboardFetcher.clipboardData) {
        AppendToClipboard(selection: selection)
    }
    //clears the clipboard and the clipboard of the device
    func clearClipboard() {
        history.removeAll()
        refresher.clear()
    }
    func clearMemory() {
        if history.count > Globals.maxItems
        {
            history.removeFirst()
            refresher.clipboard.removeFirst()
        }
    }
}
