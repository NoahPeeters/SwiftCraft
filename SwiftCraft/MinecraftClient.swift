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
    public private(set) var connectionState = ConnectionState.handshaking

    public init(tcpClient: ReactiveTCPClientProtocol, packetLibrary: PacketLibrary) {
        self.tcpClient = tcpClient
        self.packetLibrary = packetLibrary

        tcpClient.events.observeValues { [weak self] event in
            self?.handleEvent(event)
        }
    }

    public func connect() {
        tcpClient.connect()
    }

    public func connectAndLogin(username: String) {
        connect()
        sendHandshake(nextState: .login)
        sendLoginStart(username: username)
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
        let buffer = ByteBuffer(elements: bytes)
        let packetLength = try Int(VarInt32(from: buffer).value)

        guard buffer.remainingData() == packetLength else {
            fatalError("Length missmatch")
        }

        let rawPacketID = try Int(VarInt32(from: buffer).value)
        let packetID = connectionState.packetID(with: rawPacketID)

        try packetLibrary.parseAndHandle(buffer, packetID: packetID, with: self)
    }
}
