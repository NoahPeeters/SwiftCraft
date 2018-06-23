//
//  Data+MinecraftHexString.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Data {
    /// Creates a hex string in the format required by Minecraft.
    /// More information can be found [here](http://wiki.vg/Protocol_Encryption#Client).
    ///
    /// - Returns: The hex string.
    public func minecraftHexString() -> String {
        var bytes = Array(self)
        let negative = bytes[0] & 0x80 > 0

        if negative {
            twoComplement(of: &bytes)
        }

        let hexString = bytes.map { (byte: Byte) -> String in
            String(format: "%02X", byte)
        }.joined()

        var foundNonNullCharacter: Bool = false
        let trimmedHexString = hexString.filter { (character: Character) -> Bool in
            if character == "0" && !foundNonNullCharacter {
                return false
            } else {
                foundNonNullCharacter = true
                return true
            }
        }

        return negative ? "-" + trimmedHexString : trimmedHexString
    }

    /// Creates the two complement of the given byte array in place.
    ///
    /// - Parameter bytes: The byte array to modify.
    private func twoComplement(of bytes: inout ByteArray) {
        var carry = true
        for index in (0..<bytes.count).reversed() {
            let newByteValue = ~bytes[index]
            if carry {
                (bytes[index], carry) = newByteValue.addingReportingOverflow(1)
            } else {
                bytes[index] = newByteValue
            }
        }
    }
}
