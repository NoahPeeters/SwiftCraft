//
//  ReadBuffer.swift
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

    /// Reads all remaining data of the buffer.
    ///
    /// - Returns: The read data.
    func readRemainingElements() -> [Element]

    /// Moves the reading head forwards.
    ///
    /// - Parameter length: The amount to move the head by.
    /// - Throws: Throws an error if the buffer is empty.
    func advance(by length: Int) throws

    /// Allows access to the raw bytes at the current position.
    ///
    /// - Parameter body: The body of the access.
    /// - Returns: The value returned by the body.
    /// - Throws: Errors throws by the body.
    /// - Attention: Dont forget to use `advance(by:)` after reading elements.
    func withUnsafePointer<R>(_ body: (UnsafePointer<Element>) throws -> R) rethrows -> R

    /// Reads one element .
    ///
    /// - Returns: The value
    /// - Throws: Throws an error if the buffer is empty.
    func loadAsType<R>() throws -> R
}

/// A buffer used to read bytes from.
public protocol ByteReadBuffer: ReadBuffer where Element == Byte {}
