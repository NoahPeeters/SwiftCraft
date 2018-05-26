//
//  UUID+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension UUID: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        var data = try buffer.read(lenght: 16)

        self = withUnsafePointer(to: &data[0]) {
            NSUUID.init(uuidBytes: $0) as UUID
        }
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        var uuid = self.uuid
        let data = withUnsafePointer(to: &uuid) {
            return Data(bytes: $0, count: 16)
        }

        buffer.write(elements: Array(data))
    }
}
