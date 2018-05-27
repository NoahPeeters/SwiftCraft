//
//  SerializablePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

// MARK: - Serializing

/// A serializable minecaft packet.
public protocol SerializablePacket {
    /// Serializes the packet and its packet id to a byte array.
    ///
    /// - Returns: The byte array.
    func serialize() -> ByteArray

    /// Serializes the packets data to a byte array.
    ///
    /// - Returns: The serialized packet data
    func serializedData() -> ByteArray

    /// The id of the packet.
    static var packetID: PacketID { get }
}

extension SerializablePacket {
    public func serialize() -> ByteArray {
        let serializedPacketID = VarInt32(Self.packetID.id).directSerialized()

        return serializedPacketID + serializedData()
    }
}

/// A packet whichs data can be serialized to a buffer.
public protocol BufferSerializablePacket: SerializablePacket {
    /// Serializes the packets data to a buffer.
    ///
    /// - Parameter buffer: The buffer to serialize the data to.
    func serializeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte
}

extension BufferSerializablePacket {
    public func serializedData() -> ByteArray {
        let writeBuffer = ByteBuffer()
        serializeData(to: writeBuffer)
        return writeBuffer.elements
    }
}

// MARK: - Docoding

/// A deserializable minecaft packet.
public protocol DeserializablePacket {
    /// The id of the packet.
    static var packetID: PacketID { get }

    init<Buffer: ReadBuffer>(from buffer: Buffer, client: MinecraftClient) throws where Buffer.Element == Byte
}

public protocol SimpleDeserializablePacket: DeserializablePacket {
    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte
}

extension SimpleDeserializablePacket {
    public init<Buffer: ReadBuffer>(from buffer: Buffer, client: MinecraftClient) throws where Buffer.Element == Byte {
        try self.init(from: buffer)
    }
}
