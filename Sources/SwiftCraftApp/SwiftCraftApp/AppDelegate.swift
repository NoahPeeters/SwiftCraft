//
//  AppDelegate.swift
//  SwiftCraftApp
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Cocoa
import SwiftCraftAppShared

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet public weak var window: NSWindow!

    private let game = SwiftCraftAppGame()

    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        game.startOffline()
    }
}
