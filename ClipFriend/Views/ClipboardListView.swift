//
//  ClipboardListView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI

struct ClipboardListView: View {
    @Environment(\.openWindow) private var openWindow
    //this refreshes it in the background
    private let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    @StateObject var viewModel = ClipboardViewModel()
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    openWindow(id: "about")
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                Spacer()
                //the clear button
                Button {
                    viewModel.clearClipboard()
                } label: {
                    Text("Clear History")
                }
                .buttonStyle(.plain)
                Spacer()
                SettingsLink {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .onAppear {
                viewModel.refresh()
            }

            Divider()

            if viewModel.history.isEmpty {
                Text("No items yet...")
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        rows
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                    }
                    //automatically scroll to the top of the list when something new is added -
                    //animations disabled here so this doesn't fight with the panel's own
                    //resize as the item count (and therefore panel height) changes
                    .onChange(of: viewModel.history.first?.id, initial: false) { _, newId in
                        guard let newId else { return }
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            proxy.scrollTo(newId, anchor: .top)
                        }
                    }
                }
            }
        }
        //hugs the actual content height, only growing up to maxPanelHeight - beyond that
        //the ScrollView above absorbs the overflow and scrolls instead of the panel growing
        .frame(maxHeight: Globals.maxPanelHeight)
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: Globals.panelWidth)
        .adaptiveGlassBackground(cornerRadius: 14)
        //the panel already resizes as items are added/removed - suppressing SwiftUI's own
        //implicit animation here keeps that from fighting with the scroll-to-top above
        .animation(nil, value: viewModel.history.count)
        .onReceive(timer) { _ in
            viewModel.refresh()
            viewModel.clearMemory()
        }
    }

    //spacing (rather than dividers) gives each row a bit of visible breathing room above
    //and below, so highlighted rows read as slightly separated instead of touching
    private var rows: some View {
        LazyVStack(spacing: 6) {
            ForEach(viewModel.history) { item in
                ClipObjectView(item: item, onCopy: viewModel.updateClipboard)
                    .id(item.id)
            }
        }
    }
}
//#Preview {
    //ClipboardListView()
//}
