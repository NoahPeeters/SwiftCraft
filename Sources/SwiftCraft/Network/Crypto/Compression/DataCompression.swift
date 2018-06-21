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
    public func inflate() -> Data? {
        return try? gunzipped()
    }

    public func deflate() -> Data? {
        return try? gzipped()
    }

    /// Rudimentary implementation of the adler32 checksum.
    /// [Source](https://github.com/mw99/DataCompression/blob/master/Sources/DataCompression.swift)
    ///
    /// - Returns: 4 byte long adler32 checksum.
    public func adler32() -> UInt32 {
        var s1: UInt32 = 1
        var s2: UInt32 = 0
        let prime: UInt32 = 65521

        for byte in self {
            s1 += UInt32(byte)
            if s1 >= prime { s1 = s1 % prime }
            s2 += s1
            if s2 >= prime { s2 = s2 % prime }
        }

        return (s2 << 16) | s1
    }
}

extension Data {
    /// Compresses the data with the deflate algorithm and adds the zip header and footer.
    ///
    /// - Returns: The compressed data.
    public func zip() -> Data? {
        var result = Data(bytes: [0x78, 0x5e])

        guard let deflated = self.deflate() else {
            return nil
        }

        result.append(deflated)

        var adler = self.adler32().bigEndian
        result.append(Data(bytes: &adler, count: MemoryLayout<UInt32>.size))

        return result
    }

    public func unzip(skipCheckSumValidation: Bool = true) -> Data? {
        // 2 byte header + 4 byte adler32 checksum
        let overhead = 6

        guard count > overhead else {
            return nil
        }

        let header: UInt16 = withUnsafeBytes { (ptr: UnsafePointer<UInt16>) -> UInt16 in
            return ptr.pointee.bigEndian
        }

        // check for the deflate stream bit & check the header checksum
        guard header >> 8 & 0b1111 == 0b1000, header % 31 == 0 else {
            return nil
        }

        guard let inflated = inflate() else {
            return nil
        }

        if skipCheckSumValidation {
            return inflated
        }

        let checkSum = withUnsafeBytes { (bytePtr: UnsafePointer<UInt8>) -> UInt32 in
            let last = bytePtr.advanced(by: count - 4)
            return last.withMemoryRebound(to: UInt32.self, capacity: 1) { (intPtr) -> UInt32 in
                return intPtr.pointee.bigEndian
            }
        }

        guard checkSum == inflated.adler32() else {
            return nil
        }
        return inflated
    }
}

extension Data {
    public func gzip() -> Data? {
        var result = Data(bytes: [0x1f, 0x8b, 0x08, 0, 0, 0, 0, 0, 0, 0])

        guard let deflated = self.deflate() else {
            return nil
        }

        result.append(deflated)

        var crc = crcHash()
        result.append(Data(bytes: &crc, count: MemoryLayout<UInt32>.size))

        var length = UInt32(count)
        result.append(Data(bytes: &length, count: MemoryLayout<UInt32>.size))

        return result
    }

    public func ungzip(skipCheckSumValidation: Bool = true) -> Data? {
        // 2 magic number + 1 alogrithm + 7 stuff + 4 checksum + 4 length
        let overhead = 18

        guard count > overhead, Array(self[0..<3]) == [0x1f, 0x8b, 0x08] else {
            return nil
        }

        guard let inflated = self.inflate() else {
            return nil
        }

        if skipCheckSumValidation {
            return inflated
        }

        let checkSums = withUnsafeBytes { (bytePtr: UnsafePointer<UInt8>) -> [UInt32] in
            let advancedPtr = bytePtr.advanced(by: count - 8)
            let buffer = advancedPtr.withMemoryRebound(to: UInt32.self, capacity: 2) { intPtr in
                return UnsafeBufferPointer(start: intPtr, count: 2)
            }
            return Array(buffer)
        }

        guard checkSums[0] == inflated.crcHash(), checkSums[1] == UInt32(inflated.count) else {
            return nil
        }
        return inflated
    }

    fileprivate func crcHash() -> UInt32 {
        return UInt32((try? CC.CRC.crc(self, mode: .crc32Adler)) ?? 0)
    }
}
