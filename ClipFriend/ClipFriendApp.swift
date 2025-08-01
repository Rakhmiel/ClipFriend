//
//  ClipFriendApp.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 7/31/25.
//

import SwiftUI
import ServiceManagement

@main
struct ClipFriendApp: App {
    init() {
            // makes it start at login
            try? SMAppService.mainApp.register()
        }
    @StateObject private var viewModel = ClipboardViewModel()
    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "doc.on.clipboard") {
            // This is the view SwiftUI will drop down when the menu icon is clicked
            ClipboardListView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
