//
//  SettingsView.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

import SwiftUI
import AppKit
import ServiceManagement

//a real, separate Settings window (like every native macOS app), rather than a screen
//pushed inside the menu bar dropdown
struct SettingsView: View {
    @State private var localmaxItems = Globals.maxItems
    @State private var startAtLogin = false
    @State private var loginItemNeedsApproval = false

    private static let maxItemsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.allowsFloats = false
        formatter.minimum = 3
        return formatter
    }()

    var body: some View {
        Form {
            Section("General") {
                Toggle("Start at Login", isOn: $startAtLogin)
                    .onChange(of: startAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            // revert to whatever the system actually reports if the call failed
                            startAtLogin = (SMAppService.mainApp.status == .enabled)
                        }
                        loginItemNeedsApproval = (SMAppService.mainApp.status == .requiresApproval)
                    }
                if loginItemNeedsApproval {
                    Text("Enable ClipFriend in System Settings > Login Items.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Storage") {
                Text("Warning: too many items will cause performance issues.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Text("Maximum Stored Items")
                    Spacer()
                    TextField("", value: $localmaxItems, formatter: Self.maxItemsFormatter)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                }
                //changes the maximum amount of stored items
                Button("Save") {
                    Globals.maxItems = Int(localmaxItems)
                }
            }

            Section {
                Button("Quit App") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 320)
        .closeWhenUnfocused()
        .onAppear {
            startAtLogin = (SMAppService.mainApp.status == .enabled)
            loginItemNeedsApproval = (SMAppService.mainApp.status == .requiresApproval)
            // menu-bar-only (accessory) apps don't automatically bring their own windows to
            // the front - without this, Settings can open hidden behind other apps' windows
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

#Preview {
    SettingsView()
}
