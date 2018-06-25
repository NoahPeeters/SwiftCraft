//
//  CollectionsSerializationTests.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 25.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class OptionalSerializationTests: QuickSpec {
    public override func spec() {
        describe("when serializes an optional UInt8") {
            it("serializes nil correctly") {
                expect(UInt8?.none.directSerialized()).to(equal([0x00]))
            }

            it("serializes 42 correctly") {
                expect(Optional(UInt8(42)).directSerialized()).to(equal([0x01, 42]))
            }
        }

        describe("when deserializes an optional UInt8") {
            it("deserializes nil correctly") {
                expect(try? UInt8?(from: [0x00])).to(equal(UInt8??.some(nil)))
            }

            it("deserializes 42 correctly") {
                expect(try? UInt8?(from: [0x01, 42])).to(equal(42))
            }
        }
    }
}

public class StringSerializationTests: QuickSpec {
    // swiftlint:disable:next function_body_length
    public override func spec() {
        describe("ascii") {
            let serializedData: ByteArray = [12, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21]
            let deserializedString = "Hello World!"

            describe("serializing") {
                it("serializes correctly") {
                    expect(deserializedString.directSerialized()).to(equal(serializedData))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? String(from: serializedData)).to(equal(deserializedString))
                }

                it("deserializes correctly with given length") {
                    let buffer = Buffer(elements: Array(serializedData[1...]))
                    expect(try? String(from: buffer, count: 12)).to(equal(deserializedString))
                }
            }
        }

        describe("emoji") {
            let serializedData: ByteArray = [4, 0xf0, 0x9f, 0x98, 0x8e]
            let deserializedString = "😎"

            describe("serializing") {
                it("serializes correctly") {
                    expect(deserializedString.directSerialized()).to(equal(serializedData))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? String(from: serializedData)).to(equal(deserializedString))
                }
            }
        }

        describe("empty string") {
            describe("serializing") {
                it("serializes correctly") {
                    expect("".directSerialized()).to(equal([0]))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? String(from: [0])).to(equal(""))
                }
            }
        }

        describe("deserializing invalid data") {
            it("throws when deserializing empty data") {
                expect { try String(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when length is longer then the remaining data") {
                expect { try String(from: [5, 42, 42]) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when the data is not valid utf8") {
                expect {
                    try String(from: [3, 0xf0, 0x9f, 0x98])
                }.to(throwError(String.TypeDeserializeError.invalidStringData))
            }

            it("throws when the data is not valid utf8 and the length is given") {
                expect {
                    try String(from: Buffer(elements: [0xf0, 0x9f, 0x98]), count: 3)
                }.to(throwError(String.TypeDeserializeError.invalidStringData))
            }
        }
    }
}
