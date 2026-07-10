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
                case (.text(let s1, _, _, _), .text(let s2, _, _, _)):
                    return s1 == s2
                case (.image(let img1, _, _, _), .image(let img2, _, _, _)):
                    // Compare image data to detect duplicates
                    return img1 == img2
                case (.file(let f1, _, _, _), .file(let f2, _, _, _)):
                    return f1.bookmark == f2.bookmark
                case (.video(let f1, _, _, _), .video(let f2, _, _, _)):
                    return f1.bookmark == f2.bookmark
                default:
                    return false
                }
            })
        }
        history.insert(contentsOf: newEntries, at: 0)
        // the fetcher's own newString/newObject/lastFileURL fields already prevent re-appending
        // duplicate content, so its array doesn't need to persist as a second history - clearing
        // it here keeps it from silently drifting out of sync with `history`
        refresher.clipboard.removeAll()
    }
    func updateClipboard(selection: ClipboardFetcher.clipboardData) {
        AppendToClipboard(selection: selection)
        // sensitive items (e.g. passwords) disappear from history once they've been pasted
        if selection.isSensitive {
            history.removeAll { $0.id == selection.id }
        }
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
        }
    }
}
