//
//  NBT.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// NBT data tree.
public struct NBT: Hashable, DeserializableDataType {
    public let value: NamedNBTNodeWrapper?

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try NamedNBTNodeWrapper(from: buffer)
    }

    /// Creates a new NBT data tree from the given data. The compression method will be detected automatlically.
    ///
    /// - Parameter data: The data to deserialize.
    /// - Throws: Deserialization errors.
    public init(data: Data) throws {
        let decompressedData = data.unzip() ?? data
        try self.init(from: Array(decompressedData))
    }

    /// Creates a new NBT data tree from the given data. The compression method will be detected automatlically.
    ///
    /// - Parameter bytes: The data to deserialize.
    /// - Throws: Deserialization errors.
    public init(bytes: ByteArray) throws {
        try self.init(data: Data(bytes: bytes))
    }

    fileprivate static func nodeType(withID id: Byte) -> NBTNode.Type {
        return [
            NBTByte.self,       // 0
            NBTByte.self,       // 1
            NBTInt16.self,      // 2
            NBTInt32.self,      // 3
            NBTInt64.self,      // 4
            NBTFloat.self,      // 5
            NBTDouble.self,     // 6
            NBTByteArray.self,  // 7
            NBTString.self,     // 8
            NBTList.self,       // 9
            NBTCompount.self    // 10
        ][Int(id)]
    }

    public var hashValue: Int {
        return value.debugDescription.hashValue
    }

    public static func == (lhs: NBT, rhs: NBT) -> Bool {
        return lhs.value.debugDescription == rhs.value.debugDescription
    }
}

/// A node in an NBT tree.
public protocol NBTNode {
    init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws
}

/// A node representing a byte.
public struct NBTByte: NBTNode {
    /// The value of the node.
    public let value: Byte

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try Byte(from: buffer)
    }
}

/// A node representing a Int16.
public struct NBTInt16: NBTNode {
    /// The value of the node.
    public let value: Int16

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try Int16(from: buffer)
    }
}

/// A node representing a Int32.
public struct NBTInt32: NBTNode {
    /// The value of the node.
    public let value: Int32

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try Int32(from: buffer)
    }
}

/// A node representing a Int64.
public struct NBTInt64: NBTNode {
    /// The value of the node.
    public let value: Int64

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try Int64(from: buffer)
    }
}

/// A node representing a FLoat.
public struct NBTFloat: NBTNode {
    /// The value of the node.
    public let value: Float

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try Float(from: buffer)
    }
}

/// A node representing a Double.
public struct NBTDouble: NBTNode {
    public let value: Double

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        value = try Double(from: buffer)
    }
}

/// A node representing a byte array.
public struct NBTByteArray: NBTNode {
    /// The value of the node.
    public let value: ByteArray

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let count = try Int32(from: buffer)
        value = try (0..<count).map { _ in
            try Byte(from: buffer)
        }
    }
}

/// A node representing a string.
public struct NBTString: NBTNode {
    /// The value of the node.
    public let value: String

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let count = try Int(Int16(from: buffer))
        value = try String(from: buffer, count: count)
    }
}

/// A node representing a list of nodes.
public struct NBTList: NBTNode {
    /// The value of the node.
    public let value: [NBTNode]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let typeID = try Byte(from: buffer)
        let count = try Int32(from: buffer)

        let type = NBT.nodeType(withID: typeID)

        value = try (0..<count).map { _ in
            try type.init(from: buffer)
        }
    }
}

/// A node representing a dictionary of strings and nodes.
public struct NBTCompount: NBTNode {
    /// The value of the node.
    public let value: [String: NBTNode]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        var values = [String: NBTNode]()

        while true {
            guard let element = try NamedNBTNodeWrapper(from: buffer) else {
                break
            }
            values[element.name] = element.value
        }

        self.value = values
    }
}

/// A wrapper for a node with a name.
public struct NamedNBTNodeWrapper {
    /// The name of the node.
    public let name: String

    /// The value of the node.
    public let value: NBTNode

    public init?<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let typeID = try Byte(from: buffer)

        guard typeID > 0 else {
            return nil
        }

        name = try NBTString(from: buffer).value

        let type = NBT.nodeType(withID: typeID)
        value = try type.init(from: buffer)
    }
}
