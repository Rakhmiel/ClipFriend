//
//  About.swift
//  ClipFriend
//

import SwiftUI
import AppKit

//a real, separate About window (like every native macOS app), rather than a screen
//pushed inside the menu bar dropdown
struct About: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Version 1")
                .font(.headline)
            Text("Made by Ryan Dobron")
            HStack(spacing: 4) {
                Text("Contact:")
                Link("rakhmieldev@gmail.com", destination: URL(string: "mailto:rakhmieldev@gmail.com")!)
            }
            HStack(spacing: 4) {
                Text("Telegram:")
                Link("@rakhmieldev", destination: URL(string: "https://t.me/rakhmieldev")!)
            }
            HStack(spacing: 4) {
                Text("Support me on")
                Link("Ko-fi", destination: URL(string: "https://ko-fi.com/rakhmiel")!)
            }
            HStack(spacing: 4) {
                Text("Support:")
                Link("https://rakhmiel.github.io/ClipFriend/", destination: URL(string: "https://rakhmiel.github.io/ClipFriend/")!)
            }
        }
        .padding(20)
        .frame(width: 340, height: 220)
        .closeWhenUnfocused()
        .onAppear {
            // menu-bar-only (accessory) apps don't automatically bring their own windows to
            // the front - without this, About can open hidden behind other apps' windows
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

#Preview {
    About()
}
