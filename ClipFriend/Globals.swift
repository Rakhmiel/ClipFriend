//
//  Globals.swift
//  ClipFriend
//
//  Created by Ryan Dobron on 8/4/25.
//

//Stores global variables

import CoreGraphics

class Globals{
    static var maxItems: Int = 100
    static let maxThumbnailDimension: CGFloat = 128
    // the clipboard dropdown's width is fixed and its height is a ceiling - it hugs its
    // actual content and only grows up to this cap, scrolling beyond it. Settings and About
    // are separate windows now, so they size themselves independently of this.
    static let panelWidth: CGFloat = 300
    static let maxPanelHeight: CGFloat = 380
    static func maximumItems(num: Int = 100) {
        maxItems = num
    }
}
