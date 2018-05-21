//
//  CodablePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A encodable minecaft packet.
public protocol EncodablePacket {
    /// Encodes the packet and its header to a byte array.
    ///
    /// - Returns: The byte array.
    func encode() -> ByteArray

    /// Encodes the packets data to a byte array.
    ///
    /// - Returns: The encoded packet data
    func encodeData() -> ByteArray

    /// The id of the packet.
    static var packetID: PacketID { get }
}

extension EncodablePacket {
    public func encode() -> ByteArray {
        let encodedPacketID = VarInt32(Self.packetID.id).directEncode()
        let encodedData = encodeData()

        let length = encodedPacketID.count + encodedData.count
        let encodedLength = VarInt32(length).directEncode()

        return encodedLength + encodedPacketID + encodedData
    }
}

/// A packet whichs data can be encoded to a buffer.
public protocol BufferEncodablePacket: EncodablePacket {
    /// Encodes the packets data to a buffer.
    ///
    /// - Parameter buffer: The buffer to encode the data to.
    func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte
}

extension BufferEncodablePacket {
    public func encodeData() -> ByteArray {
        let writeBuffer = ByteBuffer()
        encodeData(to: writeBuffer)
        return writeBuffer.elements
    }
}

/// A decodable minecaft packet.
public protocol DecodablePacket {
    /// The id of the packet.
    static var packetID: PacketID { get }

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte
}
