//
//  CompressionTests.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 24.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

private enum TestData {
    static let uncompressedData = Data(bytes:
        [42, 34, 84, 85, 28, 38, 38, 9, 75, 18, 126])

    static let zippedData = Data(bytes: [
        31, 139, 8, 0, 0, 0, 0, 0, 0, 19,
        211, 82, 10, 9, 149, 81, 83, 227,
        244, 22, 170, 3, 0, 252, 147,
        224, 135, 11, 0, 0, 0
    ])
}

public class ZipTest: QuickSpec {
    public override func spec() {
        it("compresses correctly") {
            expect(TestData.uncompressedData.zip()).to(equal(TestData.zippedData))
        }

        it("decompresses correctly") {
            expect(TestData.zippedData.unzip()).to(equal(TestData.uncompressedData))
        }

        it("cannot decompress invalid data") {
            expect(TestData.uncompressedData.unzip()).to(beNil())
        }

        it("decompress empty data as empty data") {
            expect(Data().unzip()).to(equal(Data()))
        }
    }
}

public class MessageCompressorTests: QuickSpec {
    public override func spec() {
        describe("when creating compressor with threshold") {
            var compressor: MessageCompressor!

            beforeEach {
                compressor = MessageCompressor(threshold: 10)
            }

            it("does not compress short data") {
                expect(try? compressor.compressMessage(Array(1..<7))).to(equal(Array(0..<7)))
            }

            it("compresses long data") {
                let uncompressedLengthData = VarInt32(TestData.uncompressedData.count).directSerialized()
                expect(try? compressor.compressMessage(Array(TestData.uncompressedData)))
                    .to(equal(uncompressedLengthData + Array(TestData.zippedData)))
            }

            it("does not have to decompress short data") {
                expect(try? compressor.decompressMessage(Array(0..<7))).to(equal(Array(1..<7)))
            }

            it("decompresses long data") {
                let uncompressedLengthData = VarInt32(TestData.uncompressedData.count).directSerialized()
                expect(try? compressor.decompressMessage(uncompressedLengthData + Array(TestData.zippedData)))
                    .to(equal(Array(TestData.uncompressedData)))
            }

            it("cannot decompress invalid data") {
                expect {
                    try compressor.decompressMessage([1] + Array(TestData.uncompressedData))
                }.to(throwError(MessageCompressorError.cannotDecompresData))
            }
        }
    }
}
