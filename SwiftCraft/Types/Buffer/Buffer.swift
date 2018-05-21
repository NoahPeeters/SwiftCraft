//
//  Buffer.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public typealias Byte = UInt8
public typealias ByteArray = [Byte]

/// A buffer of bytes.
public typealias ByteBuffer = Buffer<Byte>

/// Errors which can occure while using the buffer.
///
/// - noDataAvailable: Thrown when no data are available anymore.
public enum BufferError: Error {
    case noDataAvailable
}

/// A buffer which can be used for reading and writing
public class Buffer<Element> {
    /// The underlying elements.
    private(set) var elements: [Element]

    /// The current positon for reading.
    private(set) var position: Int

    /// Creates a new `Buffer`.
    ///
    /// - Parameters:
    ///   - elements: The elements in the buffer
    ///   - position: The location to start reading
    public init(elements: [Element] = [], position: Int = 0) {
        self.elements = elements
        self.position = position
    }

    /// Counts the remaining number of elements.
    ///
    /// - Returns: The reminaing number of elements.
    public func remainingData() -> Int {
        return elements.count - position
    }

    /// Clears the buffer content and resets the read position
    public func clear() {
        elements.removeAll()
        position = 0
    }
}

// MARK: - Read Buffer

extension Buffer: ReadBuffer {
    public func read(lenght: Int) throws -> [Element] {
        guard remainingData() >= lenght else {
            throw BufferError.noDataAvailable
        }

        let values = Array(elements[position..<position + lenght])
        position += lenght

        return values
    }

    public func readOne() throws -> Element {
        guard remainingData() >= 1 else {
            throw BufferError.noDataAvailable
        }

        let value = elements[position]
        position += 1

        return value
    }
}

// MARK: - Write Buffer

extension Buffer: WriteBuffer {
    public func write(elements: [Element]) {
        self.elements.append(contentsOf: elements)
    }

    public func write(element: Element) {
        elements.append(element)
    }
}