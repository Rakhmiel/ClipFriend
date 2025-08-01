//
//  ClipObjectView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI

struct ClipObjectView: View {
    let item: ClipboardFetcher.clipboardData
        var body: some View {
            //filters the input according to its data type
            switch item {
            case .text(let text):
                clipObject(item: text)
            case .image(let image):
                clipObject(item: image)
            case .none:
                Text("0")
            }
            
        }
    //this returns a view and takes a copied string as its datatype
    func clipObject(item: String) -> some View {
        HStack {
            Button {
                AppendToClipboard(selection: .text(item))
            } label: {
                Text("􀉁")
            }
            Spacer()
                .frame(minWidth: 5)
            Text(item)
                .lineLimit(3)
                .truncationMode(.tail)
        }
    }
    //this returns a view and takes a copied image as its datatype
    func clipObject(item: NSImage) -> some View {
        HStack {
            Button {
                AppendToClipboard(selection: .image(item))
            } label: {
                Text("􀉁")
            }
            Spacer()
                .frame(minWidth: 5)
            Image(nsImage: item)
                .resizable()
                .scaledToFit()
        }
    }
    }
