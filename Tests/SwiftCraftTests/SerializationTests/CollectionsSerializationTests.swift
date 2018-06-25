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

public class StringSerializationTests: QuickSpec {
    public override func spec() {
        describe("ascii") {
            let serializedData: ByteArray = [12, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21]
            let deserializedStrign = "Hello World!"

            describe("serializing") {
                it("serializes correctly") {
                    expect(deserializedStrign.directSerialized()).to(equal(serializedData))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? String(from: serializedData)).to(equal(deserializedStrign))
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
        }
    }
}
