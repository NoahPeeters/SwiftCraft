//
//  TabCompleteResponse.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Send by the server as a response to the TabCompleteRequest.
public struct TabCompleteResponsePacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0E
    }

    /// The list of completions for the last word.
    public let completions: [String]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        completions = try [String](from: buffer)
    }
}
