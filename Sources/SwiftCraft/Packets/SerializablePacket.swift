//
//  SerializablePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public protocol SerializationContext {
    /// The minecraft client.
    var client: MinecraftClient { get }

    /// The version number of the used protocol.
    var protocolVersion: Int { get }
}

// MARK: - Serializing

/// A serializable minecaft packet.
public protocol SerializablePacket: PacketIDProvider {
    /// Serializes the packet and its packet id to a byte array.
    ///
    /// - Returns: The byte array.
    func serialize(context: SerializationContext) -> ByteArray?

    /// Serializes the packets data to a byte array.
    ///
    /// - Returns: The serialized packet data.
    func serializedData(context: SerializationContext) -> ByteArray
}

extension SerializablePacket {
    public func serialize(context: SerializationContext) -> ByteArray? {
        guard let packetID = Self.packetID(context: context)?.id else {
            return nil
        }
        let serializedPacketID = VarInt32(packetID).directSerialized()

        return serializedPacketID + serializedData(context: context)
    }
}

/// A packet whichs data can be serialized to a buffer.
public protocol BufferSerializablePacket: SerializablePacket {
    /// Serializes the packets data to a buffer.
    ///
    /// - Parameter buffer: The buffer to serialize the data to.
    func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext)
}

extension BufferSerializablePacket {
    public func serializedData(context: SerializationContext) -> ByteArray {
        let writeBuffer = ByteBuffer()
        serializeData(to: writeBuffer, context: context)
        return writeBuffer.elements
    }
}

// MARK: - Deserializing

/// A deserializable minecaft packet.
public protocol DeserializablePacket: PacketIDProvider {
    init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws
}
