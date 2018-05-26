//
//  BitShifting.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

infix operator >>> : BitwiseShiftPrecedence

/// A type which can shift the raw underlying data.
public protocol BitPatternShiftable {
    /// Shifts the bit representation.
    ///
    /// - Parameters:
    ///   - lhs: The value to shift.
    ///   - rhs: The number of bits to shift.
    /// - Returns: The shifted value
    static func >>> (lhs: Self, rhs: Self) -> Self
}

extension Int64: BitPatternShiftable {
    public static func >>> (lhs: Int64, rhs: Int64) -> Int64 {
        return Int64(bitPattern: UInt64(bitPattern: lhs) >> UInt64(rhs))
    }
}

extension Int32: BitPatternShiftable {
    public static func >>> (lhs: Int32, rhs: Int32) -> Int32 {
        return Int32(bitPattern: UInt32(bitPattern: lhs) >> UInt32(rhs))
    }
}
