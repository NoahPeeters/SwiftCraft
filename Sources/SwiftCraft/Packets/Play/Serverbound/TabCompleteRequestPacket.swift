//
//  TabCompleteRequestPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sent when the user presses tab while writing text.
///
/// The server will responde with a list of completions.
public struct TabCompleteRequestPacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x01
    }

    /// The text to complete.
    public let text: String

    /// If true, the server will interprete the text as a command. This is used in command blocks.
    public let assumeCommand: Bool

    /// The position the player is looking at.
    public let position: BlockPosition?

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        text.serialize(to: buffer)
        assumeCommand.serialize(to: buffer)
        position.serialize(to: buffer)
    }
}

extension MinecraftClient {
    public func sendTabCompleteRequest(text: String, assumeCommand: Bool, position: BlockPosition?) {
        sendPacket(TabCompleteRequestPacket(text: text, assumeCommand: assumeCommand, position: position))
    }
}
