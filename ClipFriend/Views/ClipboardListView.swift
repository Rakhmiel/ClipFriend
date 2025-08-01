//
//  ClipboardListView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI

struct ClipboardListView: View {
    //this refreshes it in the background
    private let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    @StateObject var viewModel = ClipboardViewModel()
    var body: some View {
        NavigationStack
        {
            VStack{
                HStack{
                        NavigationLink(
                            destination: About(),
                            label: {
                                Text("􀅴")
                            })
                        .padding(.horizontal)
                        .padding(.top)
                        //the clear button
                        Button {viewModel.clearClipboard()
                            print("Cleared")} label: {Text("Clear History")}
                            .padding(.horizontal)
                            .padding(.top)
                        NavigationLink(
                            destination: SettingsView(),
                            label: {
                                Text("􀍟")
                            })
                        .padding(.horizontal)
                        .padding(.top)
                }
                .onAppear {
                    viewModel.refresh()
                    print("Clipboard history on appear:", viewModel.history)
                }
                if viewModel.history.isEmpty {
                    Text("No items yet...")
                        .italic()
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                } else
                {
                    VStack{
                        //this is the list that displays the data arrays
                        List(viewModel.history) { item in
                            ClipObjectView(item: item)
                                .listRowSeparator(.hidden)
                        }
                        .padding(.bottom)
                    }
                }
                EmptyView()
                    .onReceive(timer) { _ in
                        viewModel.refresh()
                        viewModel.clearMemory()
                    }
            }
        }
    }
}
//#Preview {
    //ClipboardListView()
//}
