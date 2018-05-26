//
//  MinecraftClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Baseclass for the library. It manages everything a client have to do.
open class MinecraftClient {
    /// The tcp client used to connect to the server
    private let tcpClient: TCPClientProtocol

    /// A buffer for incomplete incomming minecraft messages.
    private let incommingDataBuffer = ByteBuffer()

    /// The library of packets used for deserializing.
    private let packetLibrary: PacketLibrary

    /// Service to manage the authorization at mojang's session service.
    public let sessionServerService: SessionServerServiceProtcol

    /// The current connection state. This will influence the interpretation of packet ids.
    public var connectionState = ConnectionState.handshaking

    /// List of `Reactors`. They handle incomming and outgoing messages.
    public var reactors: [Reactor] = []

    /// Creates a new `MinecraftClient`
    ///
    /// - Parameters:
    ///   - tcpClient: The client used to connect to the server.
    ///   - packetLibrary: The packet library to use for packet deserializing.
    ///   - sessionServerService: The session server service used for authenticating.
    public init(tcpClient: TCPClientProtocol,
                packetLibrary: PacketLibrary,
                sessionServerService: SessionServerServiceProtcol) {
        self.tcpClient = tcpClient
        self.packetLibrary = packetLibrary
        self.sessionServerService = sessionServerService

        // handle events
        tcpClient.events { [weak self] event in
            self?.handleEvent(event)
        }
    }

    /// Connect the tcp client to the server
    public func connect() {
        tcpClient.connect()
    }

    /// Connects the tcp client to the server and starts the login
    public func connectAndLogin() {
        connect()
        sendHandshake(nextState: .login)
        sendLoginStart(username: sessionServerService.username)
        connectionState = .login
    }

    /// Closes the tcp client connection
    public func close() {
        tcpClient.close()
    }

    /// The host of the server.
    public var host: CFString {
        return tcpClient.host
    }

    /// The port of the server.
    public var port: UInt32 {
        return tcpClient.port
    }

    /// Handels the de- and encryption of packets.
    private var messageCryptor: ContinuousMessageCryptor?

    /// Handels the de- and compression of packets.
    private var compressor: MessageCompressor?

    /// Starts the encryption procedure and session authentication.
    ///
    /// - Parameters:
    ///   - serverID: The server id from the `EncryptionRequestPacket`.
    ///   - publicKey: The servers public key from the `EncryptionRequestPacket`.
    ///   - verifyToken: Teh verification token from the `EncryptionRequestPacket`.
    /// - Throws: Encryption errors.
    open func startEncryption(serverID: Data, publicKey: Data, verifyToken: Data) throws {
        // Generate shared secret used for aes
        let sharedSecret = generateSharedSecret()

        // Encrypt data.
        let encryptedVerifyToken = try encrypt(verifyToken, withPublicKey: publicKey)
        let encryptedSharedSecret = try encrypt(sharedSecret, withPublicKey: publicKey)

        // Calculate server hash
        let serverHash = sessionServerService.serverHash(
            serverID: serverID,
            sharedSecret: sharedSecret,
            publicKey: publicKey)

        let responsePacket = EncryptionResponsePacket(
            encryptedSharedSecret: Array(encryptedSharedSecret),
            encryptedVerifyToken: Array(encryptedVerifyToken))

        // Authenticate with the session server
        sessionServerService.joinSession(serverHash: serverHash) { [weak self] _ in
            self?.sendPacket(responsePacket)
            self?.enableEncryption(sharedSecret: sharedSecret)
        }
    }

    /// Enables aes encryption.
    ///
    /// - Parameter sharedSecret: The shared secret used for both key and iv.
    public func enableEncryption(sharedSecret: Data) {
        messageCryptor = ContinuousMessageCryptor(sharedSecret: sharedSecret)
    }

    /// Disables encryption.
    public func disableEncryption() {
        messageCryptor = nil
    }

    /// Generates a shared secret used for aes key and iv.
    ///
    /// - Returns: The generated shared secret.
    private func generateSharedSecret() -> Data {
        return CC.generateRandom(16)
    }

    /// Encrptes data with rsa.
    ///
    /// - Parameters:
    ///   - data: The data to encrypt.
    ///   - keyData: The public key.
    /// - Returns: The encrypted data.
    /// - Throws: An encryption error.
    private func encrypt(_ data: Data, withPublicKey keyData: Data) throws -> Data {
        return try CC.RSA.encrypt(
            data,
            derKey: keyData,
            tag: Data(),
            padding: .pkcs1,
            digest: .none)
    }

    /// Enables compression for all following packets with at least the size of the threshold.
    ///
    /// - Parameter threshold: The minimum size of a packet to compress.
    public func enableCompression(threshold: Int) {
        compressor = MessageCompressor(threshold: threshold)
    }

    /// Disables compression for all following packets.
    public func disableCompression() {
        compressor = nil
    }

    /// Adds a new `Reactor`. This reactor will be called aber any other reactor added so far.
    ///
    /// - Parameter reactor: The reactor to add.
    public func addReactor(_ reactor: Reactor) {
        reactors.append(reactor)
    }
}

// MARK: - MinecraftClient+Sending
extension MinecraftClient {
    /// Sends raw bytes to the server. This function should not be called manually when sending packets.
    ///
    /// - Parameter bytes: The bytes to send.
    public func send(_ bytes: ByteArray) {
        tcpClient.send(bytes: encryptMessageIfRequired(bytes))
    }

    /// Sends a packet to the server.
    ///
    /// - Parameter packet: The packet to send.
    public func sendPacket(_ packet: SerializablePacket) {
        do {
            if shouldSendPacket(packet, client: self) {
                let compressedMessage = try compressMessageIfRequired(packet.serialize())
                let messageSize = VarInt32(compressedMessage.count).directSerialized()

                send(messageSize + compressedMessage)
                didSendPacket(packet, client: self)
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - MinecraftClient+Receiving
extension MinecraftClient {
    /// Handels a new `TCPClientEvent`.
    ///
    /// - Parameter event: The event to handle.
    func handleEvent(_ event: TCPClientEvent) {
        switch event {
        case let .received(data):
            self.handleMessage(Array(data))
        default:
            break
        }
    }

    /// Handels a new incomming message.
    ///
    /// - Parameter bytes: The message to handle.
    private func handleMessage(_ bytes: ByteArray) {
        let decryptedBytes = decryptMessageIfRequired(bytes)
        incommingDataBuffer.write(elements: decryptedBytes)

        while true {
            // Read next packet length
            guard let packetLength = try? VarInt32(from: incommingDataBuffer).integer else {
                incommingDataBuffer.resetPosition()
                return
            }

            // Read next packet data
            guard let packetData = try? incommingDataBuffer.read(lenght: packetLength) else {
                incommingDataBuffer.resetPosition()
                return
            }

            // Drop read bytes.
            incommingDataBuffer.dropReadElements()

            // Handle packet
            do {
                try handlePacketData(packetData)
            } catch {
                if case let PacketLibraryError.unknowPacketID(packetID) = error {
                    let hexID = String(packetID.id, radix: 16, uppercase: true)
                    print("unknown packet: \(packetID.connectionState): 0x\(hexID)")
                } else {
                    print(error)
                }
            }
        }
    }

    /// Handels the data of a new packet. This includes deserializing and reactors.
    ///
    /// - Parameter packetData: The dat of the packet.
    /// - Throws: Any error which might occure.
    private func handlePacketData(_ packetData: ByteArray) throws {
        let packetBuffer = try Buffer(elements: decompressMessageIfRequired(packetData))
        let rawPacketID = try VarInt32(from: packetBuffer).integer
        let packetID = connectionState.packetID(with: rawPacketID)

        let packet = try packetLibrary.parse(packetBuffer, packetID: packetID)
        try self.didReceivedPacket(packet, client: self)
    }
}

// MARK: - MinecraftClient+Reactor
extension MinecraftClient: Reactor {
    public func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) throws {
        try reactors.forEach {
            try $0.didReceivedPacket(packet, client: client)
        }
    }

    public func shouldSendPacket(_ packet: SerializablePacket, client: MinecraftClient) -> Bool {
        return reactors.reduce(true) {
            return $0 && $1.shouldSendPacket(packet, client: client)
        }
    }

    public func didSendPacket(_ packet: SerializablePacket, client: MinecraftClient) {
        reactors.forEach {
            $0.didSendPacket(packet, client: client)
        }
    }
}

// MARK: - MinecraftClient+Enryption
extension MinecraftClient {
    /// Encrypts a message if encryption is enabled.
    ///
    /// - Parameter bytes: The bytes to encrypt.
    /// - Returns: The encrypted bytes of encryption is enabled. Otherwise the input bytes.
    private func encryptMessageIfRequired(_ bytes: ByteArray) -> ByteArray {
        guard let messageCryptor = messageCryptor else {
            return bytes
        }

        return Array(messageCryptor.encryptOutgoingMessage(Data(bytes: bytes)))
    }

    /// Decryptes a message if encryption is enabled.
    ///
    /// - Parameter bytes: The bytes to encrypt.
    /// - Returns: The decrypted bytes of encryption is enabled. Otherwise the input bytes.
    private func decryptMessageIfRequired(_ bytes: ByteArray) -> ByteArray {
        guard let messageCryptor = messageCryptor else {
            return bytes
        }

        return Array(messageCryptor.decryptIncommingMessage(Data(bytes: bytes)))
    }
}

// MARK: - MinecraftClient+Compression
extension MinecraftClient {
    /// Compresses a message if compression is enabled.
    ///
    /// - Parameter bytes: The bytes to compress.
    /// - Returns: The compressed bytes of compression is enabled. Otherwise the input bytes.
    /// - Throws: And error which might occure.
   private  func compressMessageIfRequired(_ bytes: ByteArray) throws -> ByteArray {
        return try compressor?.compressMessage(bytes) ?? bytes
    }

    /// Decompresses a message if compression is enabled.
    ///
    /// - Parameter bytes: The bytes to decompress.
    /// - Returns: The decompressed bytes of compression is enabled. Otherwise the input bytes.
    /// - Throws: And error which might occure.
    private func decompressMessageIfRequired(_ bytes: ByteArray) throws -> ByteArray {
        return try compressor?.decompressMessage(bytes) ?? bytes
    }
}
