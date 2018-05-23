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
    private let incommingDataBuffer = ByteBuffer()
    private let packetLibrary: PacketLibrary
    public let sessionServerService: SessionServerServiceProtcol
    public var connectionState = ConnectionState.handshaking

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

    var messageCryptor: ContinuousMessageCryptor?
    var compressor: MessageCompressor?

    public func enableEncryption(sharedSecret: Data) {
        messageCryptor = ContinuousMessageCryptor(sharedSecret: sharedSecret)
    }

    public func disableEncryption() {
        messageCryptor = nil
    }

    public func enableCompression(threshold: Int) {
        compressor = MessageCompressor(threshold: threshold)
    }

    public func disableCompression() {
        compressor = nil
    }
}

// MARK: - Sending
extension MinecraftClient {
    public func send(_ bytes: ByteArray) {
        tcpClient.output.send(value: encryptMessageIfRequired(bytes))
    }

    public func sendPacket(_ packet: EncodablePacket) {
        do {
            let compressedMessage = try compressMessageIfRequired(packet.encode())
            let messageSize = VarInt32(compressedMessage.count).directEncode()

            send(messageSize + compressedMessage)
        } catch {
            print(error)
        }
    }
}

// MARK: - Receiving
extension MinecraftClient {
    func handleEvent(_ event: TCPClientEvent) {
        switch event {
        case let .received(data):
            self.handleMessage(Array(data))
        default:
            break
        }
    }

    private func handleMessage(_ bytes: ByteArray) {
        let decryptedBytes = decryptMessageIfRequired(bytes)
        incommingDataBuffer.write(elements: decryptedBytes)

        while true {
            guard let packetLength = try? Int(VarInt32(from: incommingDataBuffer).value) else {
                incommingDataBuffer.resetPosition()
                return
            }

            guard let packetData = try? incommingDataBuffer.read(lenght: packetLength) else {
                incommingDataBuffer.resetPosition()
                return
            }

            incommingDataBuffer.dropReadElements()

            do {
                try handlePackage(packetData)
            } catch {
                print(error)
            }
        }
    }

    private func handlePackage(_ packetData: ByteArray) throws {
        let packetBuffer = try Buffer(elements: decompressMessageIfRequired(packetData))
        let rawPacketID = try Int(VarInt32(from: packetBuffer).value)
        let packetID = connectionState.packetID(with: rawPacketID)

        try packetLibrary.parseAndHandle(packetBuffer, packetID: packetID, with: self)
    }
}

extension MinecraftClient {
    func encryptMessageIfRequired(_ bytes: ByteArray) -> ByteArray {
        guard let messageCryptor = messageCryptor else {
            return bytes
        }

        return Array(messageCryptor.encryptOutgoingMessage(Data(bytes: bytes)))
    }

    func decryptMessageIfRequired(_ bytes: ByteArray) -> ByteArray {
        guard let messageCryptor = messageCryptor else {
            return bytes
        }

        return Array(messageCryptor.decryptIncommingMessage(Data(bytes: bytes)))
    }
}

extension MinecraftClient {
    func compressMessageIfRequired(_ bytes: ByteArray) throws -> ByteArray {
        return try compressor?.compressMessage(bytes) ?? bytes
    }

    func decompressMessageIfRequired(_ bytes: ByteArray) throws -> ByteArray {
        return try compressor?.decompressMessage(bytes) ?? bytes
    }
}
