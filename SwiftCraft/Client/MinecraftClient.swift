//
//  MinecraftClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public class MinecraftClient {
    private let tcpClient: ReactiveTCPClientProtocol
    private let packetLibrary: PacketLibrary
    public let sessionServerService: SessionServerServiceProtcol
    public private(set) var connectionState = ConnectionState.handshaking

    public init(tcpClient: ReactiveTCPClientProtocol,
                packetLibrary: PacketLibrary,
                sessionServerService: SessionServerServiceProtcol) {
        self.tcpClient = tcpClient
        self.packetLibrary = packetLibrary
        self.sessionServerService = sessionServerService

        tcpClient.events.observeValues { [weak self] event in
            self?.handleEvent(event)
        }
    }

    public func connect() {
        tcpClient.connect()
    }

    public func connectAndLogin() {
        connect()
        sendHandshake(nextState: .login)
        sendLoginStart(username: sessionServerService.username)
        connectionState = .login
    }

    public func close() {
        tcpClient.close()
    }

    public var host: CFString {
        return tcpClient.host
    }

    public var port: UInt32 {
        return tcpClient.port
    }

    var aesCipher: AESCipher?

    public func enableEncryption(sharedSecret: Data) {
        aesCipher = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
    }

    public func disableEncryption() {
        aesCipher = nil
    }
}

// MARK: - Sending
extension MinecraftClient {
    public func send(_ bytes: ByteArray) {
        tcpClient.output.send(value: bytes)
    }

    public func sendPacket(_ packet: EncodablePacket) {
        send(packet.encode())
    }
}

// MARK: - Receiving
extension MinecraftClient {
    func handleEvent(_ event: TCPClientEvent) {
        switch event {
        case let .received(data):
            do {
                try self.handleMessage(Array(data))
            } catch {
                print(error)
            }
        default:
            break
        }
    }

    func handleMessage(_ bytes: ByteArray) throws {
        let buffer = ByteBuffer(elements: decodeMessage(bytes))
        print(buffer.elements.count)
        let packetLength = try Int(VarInt32(from: buffer).value)

        guard buffer.remainingData() == packetLength else {
            fatalError("Length missmatch")
        }

        let rawPacketID = try Int(VarInt32(from: buffer).value)
        let packetID = connectionState.packetID(with: rawPacketID)

        try packetLibrary.parseAndHandle(buffer, packetID: packetID, with: self)
    }

    func decodeMessage(_ bytes: ByteArray) -> ByteArray {
        guard let aesCipher = aesCipher else {
            return bytes
        }

        return Array(aesCipher.decrypt(Data(bytes: bytes)))
    }
}
