//
//  ClipObjectView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI
import AppKit

struct ClipObjectView: View {
    let item: ClipboardFetcher.clipboardData
    //routes the copy button through the view model rather than the pasteboard directly, so
    //sensitive items get removed from history once they're pasted
    var onCopy: (ClipboardFetcher.clipboardData) -> Void = { AppendToClipboard(selection: $0) }
    @State private var isHovering = false
        var body: some View {
            //filters the input according to its data type
            Group {
                switch item {
                case .text(let text, let sensitive, let source, _):
                    maskedIfNeeded(sensitive: sensitive, source: source) { clipObject(item: text) }
                case .image(let image, let sensitive, let source, _):
                    maskedIfNeeded(sensitive: sensitive, source: source) { clipObject(item: image) }
                case .file(let ref, let sensitive, let source, _):
                    maskedIfNeeded(sensitive: sensitive, source: source) { clipObject(item: ref, isVideo: false) }
                case .video(let ref, let sensitive, let source, _):
                    maskedIfNeeded(sensitive: sensitive, source: source) { clipObject(item: ref, isVideo: true) }
                case .none(_, _):
                    Text("0")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
                    .padding(.horizontal, 6)
            )
            .contentShape(Rectangle())
            .onHover { hovering in isHovering = hovering }
        }
    //sensitive items (e.g. passwords) are masked by default, showing only where the content
    //came from - hovering reveals the actual content (and its normal copy button) the same
    //way a non-sensitive row would render
    @ViewBuilder
    private func maskedIfNeeded<Content: View>(sensitive: Bool, source: String?, @ViewBuilder content: () -> Content) -> some View {
        if sensitive && !isHovering {
            HStack {
                Image(systemName: "lock.fill")
                if let source {
                    Text("Securely pasted from \(source)")
                } else {
                    Text("Securely copied item")
                }
            }
            .foregroundStyle(.secondary)
            .italic()
        } else {
            content()
        }
    }
    //this returns a view and takes a copied string as its datatype
    func clipObject(item: String) -> some View {
        HStack {
            Button {
                onCopy(self.item)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
            Spacer()
                .frame(minWidth: 5)
            Text(item)
                .lineLimit(3)
                .truncationMode(.tail)
        }
    }
    //this returns a view and takes a copied image as its datatype
    func clipObject(item: Data) -> some View {
        HStack {
            Button {
                onCopy(self.item)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
            Spacer()
                .frame(minWidth: 5)
            //decodes the image data
            if let nsImage = NSImage(data: item) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
            }
        }
    }
    //this returns a view for a copied file or video reference (never holds the file's bytes)
    func clipObject(item: FileReference, isVideo: Bool) -> some View {
        HStack {
            Button {
                onCopy(self.item)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
            Spacer()
                .frame(minWidth: 5)
            if let thumbData = item.thumbnail, let nsImage = NSImage(data: thumbData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: isVideo ? "film" : "doc")
                    .frame(width: 56, height: 56)
            }
            Text(item.displayName)
                .lineLimit(2)
                .truncationMode(.middle)
        }
    }
    }
