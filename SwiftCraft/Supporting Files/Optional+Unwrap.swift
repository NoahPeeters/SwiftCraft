//
//  Optional+Unwrap.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Optional {
    /// Returns the value if not nil otherwise throws the error.
    ///
    /// - Parameter error: The error to throws.
    /// - Returns: The value.
    /// - Throws: The error.
    internal func unwrap(_ error: Error) throws -> Wrapped {
        if let value = self {
            return value
        } else {
            throw error
        }
    }
}
