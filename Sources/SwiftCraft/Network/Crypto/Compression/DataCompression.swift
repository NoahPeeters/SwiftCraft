//
//  DataCompression.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Gzip

extension Data {
    /// Compresses the data with the deflate algorithm and adds the zip header and footer.
    ///
    /// - Returns: The compressed data.
    public func zip() -> Data? {
        return try? gzipped()
    }

    /// DeCompresses the data with the deflate algorithm and removes the zip header and footer.
    ///
    /// - Returns: The decompressed data.
    public func unzip() -> Data? {
        return try? gunzipped()
    }
}
