//
//  AppDelegate.swift
//  SwiftCraftApp
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Cocoa
import SwiftCraft
import SwiftCraftReactive
import ReactiveSwift
import Result

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var minecraftClient: MinecraftClient!
    let minecraftWorld = MinecraftWorld()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        startOffline()
    }

    func startOnline() {
        //        UserDefaults.standard.removeObject(forKey: "accessToken")

        let passwordCredentials = loadCredentials() ?? UserLoginPasswordCredentials.readFromEnvironment()
        let loginService = UserLoginService()

        print("Logging in with \(passwordCredentials)")
        loginService.loginRequest(credentials: passwordCredentials, requestUser: false).startWithResult { response in
            switch response {
            case let .success(login):
                self.saveSessionCredentials(login)
                self.createMinecraftClient(sessionServerService: SessionServerService(authenticationProvider: login))

                DispatchQueue.main.sync {
                    self.minecraftClient.connectAndLogin()
                }

            case let .failure(error):
                print("Login failed \(error)")
                exit(1)
            }
        }
    }

    func startOffline() {
        createMinecraftClient(sessionServerService: OfflineSessionService(username: "Gigameter"))
        minecraftClient.connectAndLogin()
    }

    func createMinecraftClient(sessionServerService: SessionServerServiceProtocol) {
        minecraftClient = MinecraftClient(
            tcpClient: TCPClient(host: "localhost", port: 25565),
            packetLibrary: DefaultPacketLibrary(),
            sessionServerService: sessionServerService)

//        _ = minecraftClient.addReactor(MinecraftClient.singleTypeDebugPrintReactor(
//            for: EntityHeadLookPacket.self))
        _ = minecraftClient.addReactor(MinecraftClient.essentialReactors())
        _ = minecraftClient.addReactor(MinecraftClient.worldReactor(worldStatusManager: minecraftWorld))

        minecraftClient.packetSignal(ReceiveChatMessagePacket.self).observeValues {
            print($0)
        }
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

extension UserLoginPasswordCredentials {
    /// Creates new credentials by reading the username and password from the environment variables
    /// `username` and `password`.
    ///
    /// - Returns: The credentials.
    public static func readFromEnvironment() -> UserLoginPasswordCredentials {
        return UserLoginPasswordCredentials(
            username: ProcessInfo.processInfo.environment["username"]!,
            password: ProcessInfo.processInfo.environment["password"]!
        )
    }
}
