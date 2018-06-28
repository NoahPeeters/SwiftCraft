//
//  PacketLibrary.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Errors which might occure while handling a packet.
public enum PacketLibraryError: Error {
    /// The library does not know a packet with the given packet id.
    case unknowPacketID(packetID: PacketID)
}

/// A library of packets.
public protocol PacketLibrary {
    /// Searches the correct packet and tries to deserialize it.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to deserialize the packet from.
    ///   - packetID: The packet if of the packet in the buffer.
    ///   - client: The client to handle the packet.
    /// - Throws: An error which might occure.
    func parse<Buffer: ByteReadBuffer>(_ buffer: Buffer, packetID: PacketID,
                                       context: SerializationContext) throws -> DeserializablePacket
}

/// The default packet library which includes all packets currently implemented
public struct DefaultPacketLibrary: PacketLibrary {
    /// List of packet types.
    private let packets: [DeserializablePacket.Type] = [
        // Login
        DisconnectLoginPacket.self,                         // 0x00
        EncryptionRequestPacket.self,                       // 0x01
        LoginSuccessPacket.self,                            // 0x02
        SetCompressionPacket.self,                          // 0x03

        // Status
        StatusResponsePacket.self,                          // 0x00

        // Play
        SpawnObjectPacket.self,                             // 0x00
        SpawnExperienceOrbPacket.self,                      // 0x01
        SpawnGlobalEntityPacket.self,                       // 0x02
        SpawnMobPacket.self,                                // 0x03
        SpawnPaintingPacket.self,                           // 0x04
        SpawnPlayerPacket.self,                             // 0x05
        ReceivedAnimationPacket.self,                       // 0x06
        StatisticsPacket.self,                              // 0x07
        BlockBreakAnimationPacket.self,                     // 0x08
        UpdateBlockEntityPacket.self,                       // 0x09
        BlockActionPacket.self,                             // 0x0A
        BlockChangePacket.self,                             // 0x0B
        ServerDifficultyPacket.self,                        // 0x0D
        TabCompleteResponsePacket.self,                     // 0x0E
        ReceiveChatMessagePacket.self,                      // 0x0F
        MultiBlockChangePacket.self,                        // 0x10
        WindowItemsPacket.self,                             // 0x14
        SetSlotPacket.self,                                 // 0x16
        PluginMessageReceivedPacket.self,                   // 0x18
        DisconnectPlayPacket.self,                          // 0x1A
        EntityStatusPacket.self,                            // 0x1B
        UnloadChunkPacket.self,                             // 0x1D
        ChangeGameStatePacket.self,                         // 0x1E
        KeepaliveRequestPacket.self,                        // 0x1F
        ChunkDataPacket.self,                               // 0x20
        EffectPacket.self,                                  // 0x21
        ParticlePacket.self,                                // 0x22
        JoinGamePacket.self,                                // 0x23
        EntityRelativeMovePacket.self,                      // 0x26
        EntityLookAndRelativeMovePacket.self,               // 0x27
        EntityLookPacket.self,                              // 0x28
        ReceivedPlayerAbilitiesPacket.self,                 // 0x2C
        PlayerListPacket.self,                              // 0x2E
        PlayerPositionAndLookReceivedPacket.self,           // 0x2F
        UnlockRecipesPacket.self,                           // 0x31
        DestroyEntitiesPacket.self,                         // 0x32
        EntityHeadLookPacket.self,                          // 0x36
        WorldBorderPacket.self,                             // 0x38
        HeldItemChangedReceivedPacket.self,                 // 0x3A
        EntityMetadataPacket.self,                          // 0x3C
        AttachEntityPacket.self,                            // 0x3D
        EntityVelocityPacket.self,                          // 0x3E
        EntityEquipmentPacket.self,                         // 0x3F
        SetExperiencePacket.self,                           // 0x40
        UpdateHealthPacket.self,                            // 0x41
        SpawnPositionPacket.self,                           // 0x46
        TimeUpdatePacket.self,                              // 0x47
        SoundEffectPacket.self,                             // 0x49
        CollectItemPacket.self,                             // 0x4B
        EntityTeleportPacket.self,                          // 0x4C
        AdvancementsPacket.self,                            // 0x4D
        EntityPropertiesPacket.self                         // 0x4E
    ]

    /// Creates a new packet library.
    public init() {}

    /// Parses a buffer and returns the packet.
    ///
    /// - Parameters:
    ///   - buffer: The buffer with the raw packet data. This buffer must not contain the packet id.
    ///   - packetID: The packet id of the packet in  the buffer.
    /// - Returns: The parsed packet.
    /// - Throws: An `PacketLibraryError.unknowPacketID` error if the packet is unknown.
    ///           If the packet deserializing throws an error the error is forwared.
    public func parse<Buffer: ByteReadBuffer>(_ buffer: Buffer, packetID: PacketID,
                                              context: SerializationContext) throws -> DeserializablePacket {
        guard let packetType = packets.first(where: { $0.packetID(context: context) == packetID }) else {
            throw PacketLibraryError.unknowPacketID(packetID: packetID)
        }

        return try packetType.init(from: buffer, context: context)
    }
}
