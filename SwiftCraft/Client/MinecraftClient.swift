//
//  MinecraftClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

open class MinecraftClient {
    private let tcpClient: ReactiveTCPClientProtocol
    private let incommingDataBuffer = ByteBuffer()
    private let packetLibrary: PacketLibrary
    public let sessionServerService: SessionServerServiceProtcol
    public var connectionState = ConnectionState.handshaking
    public var reactors: [Reactor] = []

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

    open func startEncryption(serverID: Data, publicKey: Data, verifyToken: Data) throws {
        let sharedSecret = generateSharedSecret()

        let encryptedVerifyToken = try encrypt(verifyToken, withPublicKey: publicKey)
        let encryptedSharedSecret = try encrypt(sharedSecret, withPublicKey: publicKey)

        let serverHash = sessionServerService.serverHash(
            serverID: serverID,
            sharedSecret: sharedSecret,
            publicKey: publicKey)

        let responsePacket = EncryptionResponsePacket(
            encryptedSharedSecret: Array(encryptedSharedSecret),
            encryptedVerifyToken: Array(encryptedVerifyToken))

        sessionServerService.joinSessionRequest(serverHash: serverHash).startWithResult { [weak self] _ in
            self?.sendPacket(responsePacket)
            self?.enableEncryption(sharedSecret: sharedSecret)
        }
    }

    public func enableEncryption(sharedSecret: Data) {
        messageCryptor = ContinuousMessageCryptor(sharedSecret: sharedSecret)
    }

    public func disableEncryption() {
        messageCryptor = nil
    }

    public func generateSharedSecret() -> Data {
        return CC.generateRandom(16)
    }

    private func encrypt(_ data: Data, withPublicKey keyData: Data) throws -> Data {
        return try CC.RSA.encrypt(
            data,
            derKey: keyData,
            tag: Data(),
            padding: .pkcs1,
            digest: .none)
    }

    public func enableCompression(threshold: Int) {
        compressor = MessageCompressor(threshold: threshold)
    }

    public func disableCompression() {
        compressor = nil
    }

    public func addReactor(_ reactor: Reactor) {
        reactors.append(reactor)
    }
}

// MARK: - Sending
extension MinecraftClient {
    public func send(_ bytes: ByteArray) {
        tcpClient.output.send(value: encryptMessageIfRequired(bytes))
    }

    public func sendPacket(_ packet: EncodablePacket) {
        do {
            if shouldSendPacket(packet, client: self) {
                let compressedMessage = try compressMessageIfRequired(packet.encode())
                let messageSize = VarInt32(compressedMessage.count).directEncode()

                send(messageSize + compressedMessage)
                didSendPacket(packet, client: self)
            }
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
                try handlePacketData(packetData)
            } catch {
//                print(error)
            }
        }
    }

    private func handlePacketData(_ packetData: ByteArray) throws {
        let packetBuffer = try Buffer(elements: decompressMessageIfRequired(packetData))
        let rawPacketID = try Int(VarInt32(from: packetBuffer).value)
        let packetID = connectionState.packetID(with: rawPacketID)

        let packet = try packetLibrary.parse(packetBuffer, packetID: packetID)
        try handlePacket(packet)
    }

    private func handlePacket(_ packet: ReceivedPacket) throws {
        try self.didReceivedPacket(packet, client: self)
    }
}

extension MinecraftClient: Reactor {
    public func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) throws {
        try reactors.forEach {
            try $0.didReceivedPacket(packet, client: client)
        }
    }

    public func shouldSendPacket(_ packet: EncodablePacket, client: MinecraftClient) -> Bool {
        return reactors.reduce(true) {
            return $0 && $1.shouldSendPacket(packet, client: client)
        }
    }

    public func didSendPacket(_ packet: EncodablePacket, client: MinecraftClient) {
        reactors.forEach {
            $0.didSendPacket(packet, client: client)
        }
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
