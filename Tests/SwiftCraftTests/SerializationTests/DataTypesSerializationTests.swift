//
//  DataTypesSerializationTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class PositionSerializationTests: QuickSpec {
    public override func spec() {
        describe("zero position") {
            let serializedData: ByteArray = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            let deserializedPosition = BlockPosition(x: 0, y: 0, z: 0)

            describe("serializing") {
                it("serializes correctly") {
                    expect(deserializedPosition.directSerialized()).to(equal(serializedData))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? BlockPosition(from: serializedData)).to(equal(deserializedPosition))
                }
            }
        }

        describe("positive position") {
            let serializedData: ByteArray = [0x00, 0x00, 0x0a, 0x80, 0xac, 0x00, 0x00, 0x2c]
            let deserializedPosition = BlockPosition(x: 42, y: 43, z: 44)

            describe("serializing") {
                it("serializes correctly") {
                    expect(deserializedPosition.directSerialized()).to(equal(serializedData))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? BlockPosition(from: serializedData)).to(equal(deserializedPosition))
                }
            }
        }

        describe("negative position") {
            let serializedData: ByteArray = [0xff, 0xff, 0xf5, 0x80, 0x03, 0xff, 0xff, 0xd4]
            let deserializedPosition = BlockPosition(x: -42, y: 0, z: -44)

            describe("serializing") {
                it("serializes correctly") {
                    expect(deserializedPosition.directSerialized()).to(equal(serializedData))
                }
            }

            describe("deserializing") {
                it("deserializes correctly") {
                    expect(try? BlockPosition(from: serializedData)).to(equal(deserializedPosition))
                }
            }
        }
    }
}

public class UUIDSerializationTests: QuickSpec {
    public override func spec() {
        describe("when creating a uuid") {
            let uuid = UUID()

            it("serialized uuid is 16 bytes long") {
                expect(uuid.directSerialized().count).to(equal(16))
            }

            it("can be serialized and deserialized") {
                let serializedUUID = uuid.directSerialized()
                let deserializedUUID = try? UUID(from: serializedUUID)
                expect(deserializedUUID).to(equal(uuid))
            }
        }
    }
}
