//
//  ClipFriendApp.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 7/31/25.
//

import SwiftUI

@main
struct ClipFriendApp: App {
    // Login-item registration is user-controlled via the "Start at Login" toggle in
    // SettingsView. SMAppService persists that choice across launches on its own,
    // so nothing needs to happen here.
    @StateObject private var viewModel = ClipboardViewModel()
    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "doc.on.clipboard") {
            // This is the view SwiftUI will drop down when the menu icon is clicked
            ClipboardListView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)

        // Settings and About are real, separate windows - like every native macOS app -
        // rather than views pushed inside the menu bar dropdown. That sidesteps the sizing
        // fights between a fixed-size screen and the dropdown's own dynamic resizing.
        Settings {
            SettingsView()
        }

        Window("About ClipFriend", id: "about") {
            About()
        }
        .windowResizability(.contentSize)
    }
}
