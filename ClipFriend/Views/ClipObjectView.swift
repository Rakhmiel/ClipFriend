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
        var body: some View {
            //filters the input according to its data type
            switch item {
            case .text(let text, _):
                clipObject(item: text)
            case .image(let image, _):
                clipObject(item: image)
            case .none(_, _):
                Text("0")
            }
            
        }
    //this returns a view and takes a copied string as its datatype
    func clipObject(item: String) -> some View {
        HStack {
            Button {
                AppendToClipboard(selection: .text(item))
            } label: {
                Image(systemName: "doc.on.doc")
            }
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
                AppendToClipboard(selection: .image(item))
            } label: {
                Image(systemName: "doc.on.doc")
            }
            Spacer()
                .frame(minWidth: 5)
            //decodes the image data
            if let nsImage = NSImage(data: item) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }
        }
    }
    }
