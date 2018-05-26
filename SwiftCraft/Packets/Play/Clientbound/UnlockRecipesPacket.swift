//
//  UnlockRecipesPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet send once per second with the current time.
public struct UnlockRecipesPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x31)

    /// If true, then the crafting book will be open when the player opens its inventory.
    public let openCraftingBook: Bool

    /// If true, then the filtering option is active when the players opens its inventory.
    public let filterCraftable: Bool

    /// The action to perform.
    public let action: Action

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let mode = try VarInt32(from: buffer).value

        openCraftingBook = try Bool(from: buffer)
        filterCraftable = try Bool(from: buffer)

        let firstArray = try [VarInt32](from: buffer).map { RecipeID($0.value) }

        if mode == 0 {
            let secondArray = try [VarInt32](from: buffer).map { RecipeID($0.value) }
            action = .initList(list1: firstArray, list2: secondArray)
        } else if mode == 1 {
            action = .add(list: firstArray)
        } else {
            action = .remove(list: firstArray)
        }
    }

    /// The different actions the server can request.
    ///
    /// - initList: This will init the crafting book. The first list contains all elements to add to the crafting book
    ///             to restore the crafting book from the previous sessions. The second list is like the list from
    ///             the `add` action.
    /// - add: This will add all elements from the list to the crafting book and show a notification.
    /// - remove: This will remove all elements of the list from the crafting book.
    public enum Action {
        case initList(list1: [RecipeID], list2: [RecipeID])
        case add(list: [RecipeID])
        case remove(list: [RecipeID])
    }
}
