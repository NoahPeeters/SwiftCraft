//
//  SwiftCraftAppGame.swift
//  SwiftCraftApp
//
//  Created by Noah Peeters on 22.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftCraft
import SwiftCraftReactive

public class SwiftCraftAppGame {
    private var minecraftClient: MinecraftClient!
    private let minecraftWorld = MinecraftWorld()

    public init() {}

    public func startOnline() {
//        UserDefaults.standard.removeObject(forKey: "accessToken")

        let passwordCredentials = loadCredentials() ?? UserLoginPasswordCredentials.readFromEnvironment()
        let loginService = UserLoginService()

        print("Logging in with \(passwordCredentials)")
        loginService.loginRequest(credentials: passwordCredentials, requestUser: false).startWithResult { response in
            switch response {
            case let .success(login):
                self.saveSessionCredentials(login)
                self.createMinecraftClient(sessionServerService: SessionServerService(authenticationProvider: login))

                guard self.minecraftClient.connectAndLogin() else {
                    print("Connection failed")
                    exit(1)
                }
            case let .failure(error):
                print("Login failed \(error)")
                exit(1)
            }
        }
    }

    public func startOffline() {
        createMinecraftClient(sessionServerService: OfflineSessionService(username: "Player"))
        guard self.minecraftClient.connectAndLogin() else {
            print("Connection failed")
            exit(0)
        }
    }

    private func createMinecraftClient(sessionServerService: SessionServerServiceProtocol) {
        let networkLayer = MinecraftClientTCPNetworkLayer(
            tcpClient: TCPClient(host: "mcsl.nemegaming.org", port: 25565),
            packetLibrary: DefaultPacketLibrary())

        minecraftClient = MinecraftClient(
            networkLayer: networkLayer,
            sessionServerService: sessionServerService)

        _ = minecraftClient.addReactor(MinecraftClient.essentialReactors())
//        _ = minecraftClient.addReactor(MinecraftClient.worldReactor(worldStatusManager: minecraftWorld))

        minecraftClient.packetSignal(ReceiveChatMessagePacket.self).observeValues { [weak self] messageData in
            let message = messageData.message.message.string(translationManager: EnglishTranslationManager())

            guard !message.isEmpty else {
                return
            }

            print(message)
            self?.reactToQuiz(message: message)
            self?.reactToCapture(message: message)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.minecraftClient.sendMessage("/skyblock")

            var zOffset = 0.0
            if #available(OSXApplicationExtension 10.12, *) {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.minecraftClient.sendPlayerPosition(x: 7.5, feetY: 170, z: -5.5 + zOffset, isOnGround: true)
                    zOffset = zOffset == 0 ? 1 : 0
                }
            }
        }

        networkLayer.onClose {
            print("Connection closed \($0)")
        }
    }

    private func reactToQuiz(message: String) {
        guard let regularExpression = try? NSRegularExpression(
            pattern: "\\[ChatGame\\] Solve (\\d*) (.) (\\d*) to get rewards!",
            options: []) else {
                return
        }

        let nsMessage = message as NSString

        guard let match = regularExpression.firstMatch(in: message, options: [],
                                                       range: NSRange(location: 0, length: nsMessage.length)) else {
                                                        return
        }

        guard let firstNumber = Int(nsMessage.substring(with: match.range(at: 1))),
            let secondNumber = Int(nsMessage.substring(with: match.range(at: 3))) else {
                return
        }

        let operation = nsMessage.substring(with: match.range(at: 2))

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            switch operation {
            case "+": self.minecraftClient.sendMessage("\(firstNumber + secondNumber)")
            case "-": self.minecraftClient.sendMessage("\(firstNumber - secondNumber)")
            case "*": self.minecraftClient.sendMessage("\(firstNumber * secondNumber)")
            case "÷": self.minecraftClient.sendMessage("\(firstNumber / secondNumber)")
            default: print("unknown operation \(operation)")
            }
        }
    }

    /// Loads sessioncredentials from user default if present.
    ///
    /// - Returns: The loaded credentials or nil if not present.
    private func loadCredentials() -> UserLoginCredentials? {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
            let clientToken = UserDefaults.standard.string(forKey: "clientToken") else {
                return nil
        }
        return SimpleUserLoginSessionCredentials(accessToken: accessToken, clientToken: clientToken)
    }

    /// Saves credentials to user defaults
    ///
    /// - Parameter credentials: The credentials to save.
    private func saveSessionCredentials<Credentials: UserLoginSessionCredentials>(_ credentials: Credentials) {
        UserDefaults.standard.set(credentials.accessToken, forKey: "accessToken")
        UserDefaults.standard.set(credentials.clientToken, forKey: "clientToken")
    }
}

extension UserLoginPasswordCredentials {
    /// Creates new credentials by reading the username and password from the environment variables
    /// `username` and `password`.
    ///
    /// - Returns: The credentials.
    public static func readFromEnvironment() -> UserLoginCredentials {
        return UserLoginPasswordCredentials(
            username: ProcessInfo.processInfo.environment["username"]!,
            password: ProcessInfo.processInfo.environment["password"]!
        )
    }
}
