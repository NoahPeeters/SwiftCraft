//
//  OutputBuffer.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A buffer used to write data to.
public protocol WriteBuffer {
    /// The type of elements saved in the buffer.
    associatedtype Element

    /// Writes the elements to the buffer.
    ///
    /// - Parameter elements: The data to write
    func write(elements: [Element])

    /// Writes the element to to buffer
    ///
    /// - Parameter element: The element to write
    func write(element: Element)

    /// Saves the raw bytes to the end of the buffer.
    ///
    /// - Parameter value: The value to append.
    func saveRaw<Value>(_ value: inout Value)

    /// Saves a copy of the raw bytes to the end of the buffer. If you have a var use `saveRaw`.
    ///
    /// - Parameter value: The value to append.
    func saveRawCopy<Value>(_ value: Value)
}

extension WriteBuffer {
    public func saveRawCopy<Value>(_ value: Value) {
        var copy = value
        saveRaw(&copy)
    }
}

/// A buffer used to write bytes to.
public protocol ByteWriteBuffer: WriteBuffer where Element == Byte {}
