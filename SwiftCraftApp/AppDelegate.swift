//
//  AppDelegate.swift
//  SwiftCraftApp
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Cocoa
import Result
import ReactiveSwift

import SwiftCraft

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var minecraftClient: MinecraftClient!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let passwordCredentials = UserLoginPasswordCredentials.readFromEnvironment()

        let loginService = UserLoginService()

        let loginRequest = loginService.loginRequest(credentials: passwordCredentials, requestUser: false)

        print("Logging in with \(passwordCredentials)")
        loginRequest.startWithResult { response in
            switch response {
            case let .success(login):
                print("Login succeeded: \(login)")
                self.minecraftClient = MinecraftClient(
                    tcpClient: ReactiveTCPClient(host: "play.lemoncloud.org", port: 25565),
                    packetLibrary: DefaultPacketLibrary(),
                    sessionServerService: SessionServerService(authenticationProvider: login))
                self.minecraftClient.connectAndLogin()

            case let .failure(error):
                print("Login failed \(error)")
                exit(1)
            }
        }
    }
}
