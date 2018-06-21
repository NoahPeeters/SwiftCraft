//
//  Data+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Data: Serializable {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let count = try VarInt32(from: buffer).integer
        let bytes = try buffer.read(lenght: count)
        self = Data(bytes)
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, count: Int) throws {
        let bytes = try buffer.read(lenght: count)
        self = Data(bytes)
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        let bytes = Array(self)

        let length = VarInt32(Int32(bytes.count))
        length.serialize(to: buffer)

        buffer.write(elements: bytes)
    }
}
