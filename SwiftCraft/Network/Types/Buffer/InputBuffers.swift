//
//  InputBuffers.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A buffer used to read data from.
public protocol ReadBuffer {
    /// The type of elements saved in the buffer.
    associatedtype Element

    /// Reads specific number of bytes.
    ///
    /// - Parameter lenght: The number of bytes to read.
    /// - Returns: The requested byte array.
    /// - Throws: Throws an error if the buffer is empty.
    func read(lenght: Int) throws -> [Element]

    /// Reads one byte from the buffer
    ///
    /// - Returns: The byte.
    /// - Throws: Throws an error if the buffer is empty
    func readOne() throws -> Element
}
