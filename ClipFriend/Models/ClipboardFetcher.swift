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
        case text(String, id: UUID = UUID())
        case image(Data, id: UUID = UUID())
        case none(String, id: UUID = UUID())
        var id: UUID {
            switch self {
            case .text(_, let id), .image(_, let id), .none(_, let id):
                return id
            }
        }
    }
    var newString: String = ""
    var newObject: Data?
    // optimizations to prevent slowdowns:
    private let workerQ = DispatchQueue(label: "ClipFriend.ClipboardFetcher", qos: .utility)
    private var lastChangeCount: Int = -1
    
    @Published var clipboard: [clipboardData] = []
    //this retrieves whatever is on the clipboard
    func retrieveClipboard() {
        let pasteboard = NSPasteboard.general
        //checks if it is text and checks if its already stored
        let change = pasteboard.changeCount
        guard change != lastChangeCount else
        {
            return
        }
        //do potentially blocking work off the main thread
        lastChangeCount = change
        workerQ.async { [weak self] in guard let self = self else {return}
            
            if let string = pasteboard.string(forType: .string) {
                if self.newString == string {
                    return
                }
                else
                {
                    self.newString = string
                    DispatchQueue.main.async {
                        self.clipboard.append(.text(string))
                        print(string)
                        print("String appended")
                    }
                    return
                }
            }
            //checks if it is an image and checks if its already stored
            // it also compresses the image
            if let tiff = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
                autoreleasepool {
                   if let rep = NSBitmapImageRep(data: tiff),
                      let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.5]) {
                       if self.newObject == jpeg {
                         return
                     } else {
                         self.newObject = jpeg
                         DispatchQueue.main.async {
                             self.clipboard.append(.image(jpeg))
                             print("Image appended")
                         }
                         return
                     }
                }
            }
               
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
