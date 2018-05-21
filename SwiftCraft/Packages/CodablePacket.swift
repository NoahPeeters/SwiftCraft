//
//  CodablePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

protocol EncodablePacket {
    func encode() -> ByteArray
}

protocol DecodablePacket {
    init(from data: ByteArray) throws
}
