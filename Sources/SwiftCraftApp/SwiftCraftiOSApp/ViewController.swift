//
//  ViewController.swift
//  SwiftCraftiOSApp
//
//  Created by Noah Peeters on 23.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import UIKit
import SwiftCraft

public class ViewController: UIViewController, Reactor {

    @IBOutlet public weak var displayLabel: UILabel!

    private let client = MinecraftClient(
        tcpClient: TCPClient(host: "192.168.200.36", port: 25565),
        packetLibrary: DefaultPacketLibrary(),
        sessionServerService: OfflineSessionService(username: "Gigameter"))

    public override func viewDidLoad() {
        super.viewDidLoad()
        _ = client.addReactor(MinecraftClient.essentialReactors())
        _ = client.addReactor(self)

        if !client.connectAndLogin() {
            print("Connection failed.")
        } else {
            print("Connected.")
        }
    }

    public func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) {
        displayLabel.text = "\(packet)".components(separatedBy: "(").first
    }
}
