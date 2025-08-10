//
//  SettingsView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI
import AppKit

//settings view
// so far the only settings are the maximum amount of items stored and a button to quit the app
struct SettingsView: View {
    @State private var localmaxItems = Globals.maxItems
    var body: some View {
        NavigationStack
        {
            VStack {
                Button("Quit App") {
                    NSApplication.shared.terminate(nil)
                }
                .padding(.bottom)
                .padding(.top)
                    Text("Maximum Stored Items:")
                    Text("Warning: Too many items will cause performance issues.")
                    .padding(.top)
                    TextField("Maximum Stored Items: ", value: $localmaxItems, formatter: {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .none
                        formatter.allowsFloats = false
                        formatter.minimum = 3
                        return formatter
                        }())
                    .padding()
                    .textScale(.default)
                //changes the maximum amount of stored items
                Button("Save") {
                    Globals.maxItems = Int(localmaxItems)
                }
                .padding(.bottom)
                }
        }
        .navigationTitle(Text("Settings"))
    }
}

#Preview {
    SettingsView()
}
