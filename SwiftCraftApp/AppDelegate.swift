//
//  AppDelegate.swift
//  SwiftCraftApp
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Cocoa
import SwiftCraft

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let minecraftClient = MinecraftClient(
        tcpClient: ReactiveTCPClient(host: "localhost", port: 25565),
        packetLibrary: DefaultPacketLibrary())

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        minecraftClient.connectAndLogin(username: "Gigameter")
    }
}
