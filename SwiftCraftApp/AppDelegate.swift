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

//        UserDefaults.standard.removeObject(forKey: "accessToken")

        let passwordCredentials = loadCredentials() ?? UserLoginPasswordCredentials.readFromEnvironment()
        let loginService = UserLoginService()
        let loginRequest = loginService.loginRequest(credentials: passwordCredentials, requestUser: false)

        print("Logging in with \(passwordCredentials)")
        loginRequest.startWithResult { response in
            switch response {
            case let .success(login):
                print("Login succeeded: \(login)")
                self.saveSessionCredentials(login)
                self.createMincraftClient(login: login)

                DispatchQueue.main.sync {
                    self.minecraftClient.connectAndLogin()
                }

            case let .failure(error):
                print("Login failed \(error)")
                exit(1)
            }
        }
    }

    func createMincraftClient(login: AuthenticationProvider) {
        minecraftClient = MinecraftClient(
//            tcpClient: ReactiveTCPClient(host: "play.lemoncloud.org", port: 25565),
            tcpClient: ReactiveTCPClient(host: "192.168.200.36", port: 25565),
            packetLibrary: DefaultPacketLibrary(),
            sessionServerService: SessionServerService(authenticationProvider: login))

        minecraftClient.addReactor(MinecraftClient.debugPrintReactor())
        minecraftClient.addReactor(MinecraftClient.essentialReactors())
    }

    /// Loads sessioncredentials from user default if present.
    ///
    /// - Returns: The loaded credentials or nil if not present.
    func loadCredentials() -> UserLoginCredentials? {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
            let clientToken = UserDefaults.standard.string(forKey: "clientToken") else {
                return nil
        }
        return SimpleUserLoginSessionCredentials(accessToken: accessToken, clientToken: clientToken)
    }

    /// Saves credentials to user defaults
    ///
    /// - Parameter credentials: The credentials to save.
    func saveSessionCredentials(_ credentials: UserLoginSessionCredentials) {
        UserDefaults.standard.set(credentials.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(credentials.clientToken, forKey: "clientToken")
    }
}
