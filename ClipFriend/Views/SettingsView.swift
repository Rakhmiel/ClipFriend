//
//  SettingsView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var localmaxItems = Globals.maxItems
    var body: some View {
        NavigationStack
        {
            VStack {
                    Text("Maximum Stored Items:")
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
