//
//  ChatMessageLocation.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The location of a received chat messeage.
public enum ChatMessageLocation: Byte, Hashable {
    /// A normal chat message of another player.
    case chat = 0

    /// A chat message of the server.
    case systemMessage = 1

    /// A message which should be shown in the center of the screen.
    case gameInfo = 2
}
