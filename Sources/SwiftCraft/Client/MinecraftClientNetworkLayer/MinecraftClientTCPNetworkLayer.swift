//
//  MinecraftClientTCPNetworkLayer.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public class MinecraftClientTCPNetworkLayer: MinecraftClientNetworkLayer {
    /// The tcp client used to connect to the server
    private let tcpClient: TCPClientProtocol

    /// A buffer for incomplete incomming minecraft messages.
    private let incommingDataBuffer = ByteBuffer()

    /// The library of packets used for deserializing.
    private let packetLibrary: PacketLibrary

    /// Handels the de- and encryption of packets.
    private var messageCryptor: ContinuousMessageCryptor?

    /// Handels the de- and compression of packets.
    private var compressor: MessageCompressor?

    /// Handler to call on open.
    private var openHandler: (() -> Void)?

    /// Handler to call on close.
    private var closeHandler: ((ConnectionState) -> Void)?

    public weak var delegate: MinecraftClientNetworkLayerDelegate!

    public init(tcpClient: TCPClientProtocol, packetLibrary: PacketLibrary) {
        self.tcpClient = tcpClient
        self.packetLibrary = packetLibrary

        // handle events
        tcpClient.events { [weak self] event in
            self?.handleEvent(event)
        }
    }

    public func connect() -> Bool {
        return tcpClient.connect()
    }

    public func close() {
        tcpClient.close()
    }

    public var host: String {
        return tcpClient.host
    }

    public var port: Int {
        return tcpClient.port
    }
}

// MARK: - MinecraftClientTCPNetworkLayer+Sending
extension MinecraftClientTCPNetworkLayer {
    /// Sends raw bytes to the server. This function should not be called manually when sending packets.
    ///
    /// - Parameter bytes: The bytes to send.
    public func send(_ bytes: ByteArray) throws {
        try tcpClient.send(bytes: encryptMessageIfRequired(bytes))
    }

    /// Sends a packet to the server.
    ///
    /// - Parameter packet: The packet to send.
    public func sendPacket(_ packet: SerializablePacket) throws {
        guard let serializedPacket = packet.serialize(context: delegate.serializationContext) else {
            throw MinecraftClientTCPNetworkLayerError.cannotSerializePacket
        }
        let compressedMessage = try compressMessageIfRequired(serializedPacket)
        let messageSize = VarInt32(compressedMessage.count).directSerialized()

        try send(messageSize + compressedMessage)
    }

    /// Sets a handler to be called on connection open.
    ///
    /// - Parameter handler: The handler to set
    public func onOpen(handler: (() -> Void)?) {
        openHandler = handler
    }

    /// Sets a handler to be called on connection close.
    ///
    /// - Parameter handler: The handler to set
    public func onClose(handler: ((ConnectionState) -> Void)?) {
        closeHandler = handler
    }
}

// MARK: - MinecraftClientTCPNetworkLayer+Receiving
extension MinecraftClientTCPNetworkLayer {
    /// Handels a new `TCPClientEvent`.
    ///
    /// - Parameter event: The event to handle.
    private func handleEvent(_ event: TCPClientEvent) {
        switch event {
        case let .received(data):
            handleMessage(Array(data))
        case .streamOpened:
            openHandler?()
        case .streamClosed:
            closeHandler?(delegate.connectionState)
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
//                    print(" ❗️ unknown packet: \(packetID.connectionState): 0x\(hexID)")
                } else {
                    print(" ❌ \(error)")
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
        guard let delegate = delegate else {
            return
        }
        let packetID = delegate.connectionState.packetID(with: rawPacketID)

        let packet = try packetLibrary.parse(packetBuffer, packetID: packetID, context: delegate.serializationContext)
        delegate.didReceivePacket(packet)
    }
}

// MARK: - MinecraftClientTCPNetworkLayer+Enryption
extension MinecraftClientTCPNetworkLayer {
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

// MARK: - MinecraftClientTCPNetworkLayer+Compression
extension MinecraftClientTCPNetworkLayer {
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

extension MinecraftClientTCPNetworkLayer {
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
}

public enum MinecraftClientTCPNetworkLayerError: Error {
    case cannotSerializePacket
}
