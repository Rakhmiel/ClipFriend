//
//  ClipboardFetcher.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 7/31/25.
//

import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers
import ImageIO
import AVFoundation

//a reference to a file/video on disk - never holds the file's bytes, just enough
//to resolve it again and show a small preview
struct FileReference: Equatable {
    var bookmark: Data
    var displayName: String
    var thumbnail: Data?
    var utTypeIdentifier: String?
}

//this retrieves the data on the clipboard
class ClipboardFetcher: ObservableObject {
    //this is so the program can handle data other than text
    enum clipboardData: Identifiable {
        case text(String, sensitive: Bool = false, id: UUID = UUID())
        case image(Data, sensitive: Bool = false, id: UUID = UUID())
        case file(FileReference, sensitive: Bool = false, id: UUID = UUID())
        case video(FileReference, sensitive: Bool = false, id: UUID = UUID())
        case none(String, id: UUID = UUID())
        var id: UUID {
            switch self {
            case .text(_, _, let id), .image(_, _, let id),
                 .file(_, _, let id), .video(_, _, let id), .none(_, let id):
                return id
            }
        }
        var isSensitive: Bool {
            switch self {
            case .text(_, let sensitive, _), .image(_, let sensitive, _),
                 .file(_, let sensitive, _), .video(_, let sensitive, _):
                return sensitive
            case .none:
                return false
            }
        }
    }
    var newString: String = ""
    var newObject: Data?
    private var lastFileURL: URL?
    // optimizations to prevent slowdowns:
    private let workerQ = DispatchQueue(label: "ClipFriend.ClipboardFetcher", qos: .utility)
    private var lastChangeCount: Int = -1

    //marker used by password managers (1Password, etc.) to say "this item is sensitive"
    private let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
    private let transientType = NSPasteboard.PasteboardType("org.nspasteboard.TransientType")

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

        let types = pasteboard.types ?? []
        let isSensitive = types.contains(concealedType) || types.contains(transientType)

        //file/video references are checked first - a Finder file copy often carries an
        //incidental icon bitmap alongside the file URL, which would otherwise get
        //misclassified as a plain image below
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self],
                                              options: [.urlReadingFileURLsOnly: true]) as? [URL],
           let url = urls.first {
            handleFileURL(url, sensitive: isSensitive)
            return
        }

        //raw (non-file-backed) video bytes are intentionally unsupported: there's no way to
        //check their size before reading them fully into memory, and building a lightweight
        //thumbnail from raw bytes would require writing a temp file to disk first - both of
        //which conflict with keeping RAM low and never touching disk. Detect and skip so it
        //isn't silently misfiled as an image.
        if types.contains(where: { UTType($0.rawValue)?.conforms(to: .movie) == true }) {
            return
        }

        let stringSnapshot = pasteboard.string(forType: .string)
        let pasteboardData = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png)
        workerQ.async { [weak self] in guard let self = self else {return}

            if let string = stringSnapshot {
                if self.newString == string {
                    return
                }
                else
                {
                    self.newString = string
                    DispatchQueue.main.async {
                        self.clipboard.append(.text(string, sensitive: isSensitive))
                        print("String appended")
                    }
                    return
                }
            }
            //checks if it is an image and checks if its already stored
            // it also compresses the image
            workerQ.async { [weak self] in guard let self = self else {return}
                if let tiff = pasteboardData {
                    autoreleasepool {
                        if let rep = NSBitmapImageRep(data: tiff),
                           let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.5]) {
                            if self.newObject == jpeg {
                                return
                            } else {
                                self.newObject = jpeg
                                DispatchQueue.main.async {
                                    self.clipboard.append(.image(jpeg, sensitive: isSensitive))
                                    print("Image appended")
                                }
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    //creates a security-scoped bookmark + lightweight thumbnail for a copied file/video -
    //never reads or stores the file's actual contents
    private func handleFileURL(_ url: URL, sensitive: Bool) {
        guard url != lastFileURL else { return }
        lastFileURL = url
        workerQ.async { [weak self] in
            guard let self = self else { return }
            let bookmark: Data
            do {
                bookmark = try url.bookmarkData(options: .withSecurityScope,
                                                 includingResourceValuesForKeys: nil,
                                                 relativeTo: nil)
            } catch {
                print("Bookmark creation failed:", error)
                return
            }
            let contentType = (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType
            let isVideo = contentType?.conforms(to: .movie) ?? false
            let isImage = contentType?.conforms(to: .image) ?? false

            //real content previews for images/videos, generated straight from disk at a small
            //size (ImageIO/AVFoundation decode only the reduced frame, never the full file) so
            //this stays cheap regardless of how large the original image or video is
            let thumbData: Data?
            if isImage {
                thumbData = Self.imageThumbnail(for: url, maxDimension: Globals.maxThumbnailDimension)
                    ?? Self.compressedThumbnail(NSWorkspace.shared.icon(forFile: url.path), maxDimension: Globals.maxThumbnailDimension)
            } else if isVideo {
                thumbData = Self.videoThumbnail(for: url, maxDimension: Globals.maxThumbnailDimension)
                    ?? Self.compressedThumbnail(NSWorkspace.shared.icon(forFile: url.path), maxDimension: Globals.maxThumbnailDimension)
            } else {
                thumbData = Self.compressedThumbnail(NSWorkspace.shared.icon(forFile: url.path), maxDimension: Globals.maxThumbnailDimension)
            }

            let ref = FileReference(bookmark: bookmark,
                                     displayName: url.lastPathComponent,
                                     thumbnail: thumbData,
                                     utTypeIdentifier: contentType?.identifier)
            DispatchQueue.main.async {
                self.clipboard.append(isVideo ? .video(ref, sensitive: sensitive)
                                               : .file(ref, sensitive: sensitive))
                print(isVideo ? "Video appended" : "File appended")
            }
        }
    }
    //decodes a small preview frame straight from an image file on disk - ImageIO only
    //decodes pixels at the requested size, so this stays cheap even for a huge source image
    private static func imageThumbnail(for url: URL, maxDimension: CGFloat) -> Data? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])
    }
    //grabs a single small frame near the start of a video file - only that one frame is ever
    //decoded, never the whole video, so this doesn't scale with the file's size or length
    private static func videoThumbnail(for url: URL, maxDimension: CGFloat) -> Data? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: maxDimension, height: maxDimension)

        //already running on a background queue, so blocking here for the one frame we need
        //is fine - this just adapts the async generator API to this function's sync shape
        let semaphore = DispatchSemaphore(value: 0)
        var result: CGImage?
        generator.generateCGImageAsynchronously(for: CMTime(seconds: 0, preferredTimescale: 600)) { cgImage, _, _ in
            result = cgImage
            semaphore.signal()
        }
        semaphore.wait()

        guard let cgImage = result else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])
    }
    //resizes and compresses an NSImage (icon/preview) down to a small JPEG for in-memory storage
    private static func compressedThumbnail(_ image: NSImage, maxDimension: CGFloat) -> Data? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }
        let scale = min(1, maxDimension / max(size.width, size.height))
        let targetSize = NSSize(width: size.width * scale, height: size.height * scale)

        let resized = NSImage(size: targetSize)
        resized.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize))
        resized.unlockFocus()

        guard let tiff = resized.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])
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
