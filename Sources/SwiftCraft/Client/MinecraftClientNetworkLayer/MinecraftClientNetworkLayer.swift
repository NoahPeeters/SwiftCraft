//
//  MinecraftClientNetworkLayer.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public protocol MinecraftClientNetworkLayer {
    /// Returns the hostname of the server.
    var host: String { get }

    /// Returns the port of the server.
    var port: Int { get }

    var delegate: MinecraftClientNetworkLayerDelegate! { get set }

    /// Connects to the server.
    ///
    /// - Returns: True if the connection succeeded.
    func connect() -> Bool

    /// Closes the connection
    func close()

    /// - Parameters:
    ///   - packet: The packet to send.
    ///   - context: The context to use for encryption
    func sendPacket(_ packet: SerializablePacket) throws

    /// Enables aes encryption.
    ///
    /// - Parameter sharedSecret: The shared secret used for both key and iv.
    func enableEncryption(sharedSecret: Data)

    /// Disables encryption.
    func disableEncryption()

    /// Enables compression for all following packets with at least the size of the threshold.
    ///
    /// - Parameter threshold: The minimum size of a packet to compress.
    func enableCompression(threshold: Int)

    /// Disables compression for all following packets.
    func disableCompression()
}

public protocol MinecraftClientNetworkLayerDelegate: class {
    var connectionState: ConnectionState { get }
    var serializationContext: SerializationContext { get }

    func didReceivePacket(_ packet: DeserializablePacket)
}
