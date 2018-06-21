//
//  Buffer.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Alias for `UInt8`.
public typealias Byte = UInt8

/// Alias for array of `Byte`s.
public typealias ByteArray = [Byte]

/// A buffer of `Byte`s.
public typealias ByteBuffer = Buffer<Byte>

/// A buffer which can be used for reading and writing.
public class Buffer<Element> {
    /// The underlying elements.
    public private(set) var elements: [Element]

    /// The current positon for reading.
    public private(set) var position: Int

    /// Creates a new `Buffer` with the given elements and position of the reading head.
    ///
    /// - Parameters:
    ///   - elements: The elements in the buffer.
    ///   - position: The location to start reading.
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

    /// Clears the buffer content and resets the read position.
    public func clear() {
        elements.removeAll()
        position = 0
    }

    /// Resets the position to the start of the buffer.
    public func resetPosition() {
        position = 0
    }

    /// Drops all read elements.
    public func dropReadElements() {
        elements.removeFirst(position)
        resetPosition()
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

    public func readRemainingElements() -> [Element] {
        return (try? read(lenght: remainingData())) ?? []
    }

    public func advance(by length: Int) throws {
        position += length
    }

    public func withUnsafeBufferPointer<R>(_ body: (UnsafePointer<Element>) throws -> R) rethrows -> R {
        return try elements.withUnsafeBufferPointer { pointer in
            return try body(pointer.baseAddress!.advanced(by: position))
        }
    }

    public func loadAsType<R>() throws -> R {
        let returnTypeLength = MemoryLayout<R>.stride

        guard remainingData() >= returnTypeLength else {
            throw BufferError.noDataAvailable
        }

        let readElement: R = elements.withUnsafeBufferPointer { pointer in
            let base = pointer.baseAddress!
            return base.advanced(by: position).withMemoryRebound(to: R.self, capacity: 1) {
                $0.pointee
            }
        }

        try advance(by: returnTypeLength)
        return readElement
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

    public func saveRaw<Value>(_ value: inout Value) {
        let newElements = withUnsafeBytes(of: &value) { pointer in
            Array(pointer.bindMemory(to: Element.self))
        }
        write(elements: newElements)
    }
}

// MARK: - Byte Buffer

extension Buffer: ByteWriteBuffer where Element == Byte {}
extension Buffer: ByteReadBuffer where Element == Byte {}

/// Errors which can occure while using the buffer.
public enum BufferError: Error {
    /// Thrown when no data are available anymore.
    case noDataAvailable
}
