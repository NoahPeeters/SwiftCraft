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
    associatedtype Element

    /// Writes the elements to the buffer.
    ///
    /// - Parameter elements: The data to write
    func write(elements: [Element])

    /// Writes the element to to buffer
    ///
    /// - Parameter element: The element to write
    func write(element: Element)
}
