//
//  Data+MinecraftHexString.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Data {
    /// Creates a hex string in the format required by minecraft.
    ///
    /// - Returns: The hex string.
    func minecraftHexString() -> String {
        var bytes = Array(self)
        let negative = bytes[0] & 0x80 > 0

        if negative {
            twoComplement(of: &bytes)
        }

        let hexString = bytes.map { String(format: "%02X", $0) }.joined()
        var foundNonNullCharacter: Bool = false

        let trimmedHexString = hexString.filter {
            if $0 == "0" && !foundNonNullCharacter {
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
                carry = newByteValue == 0xff
                bytes[index] = newByteValue + 1
            } else {
                bytes[index] = newByteValue
            }
        }
    }
}
