//
//  CodableDataTypesTest.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class BoolCodableTests: QuickSpec {
    public override func spec() {
        describe("serializing") {
            it("serializes false") {
                expect(false.directSerialized()).to(equal([0]))
            }

            it("serializes true") {
                expect(true.directSerialized()).to(equal([1]))
            }
        }

        describe("deserializing") {
            it("deserializes false") {
                expect(try? Bool(from: [0])).to(equal(false))
            }

            it("deserializes true") {
                expect(try? Bool(from: [1])).to(equal(true))
            }

            it("throws when deserializing empty data") {
                expect { try Bool(from: []) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class UInt8CodableTest: QuickSpec {
    public override func spec() {
        describe("serializing") {
            it("serializes correctly") {
                expect(UInt8(42).directSerialized()).to(equal([42]))
            }
        }

        describe("deserializing") {
            it("deserializes correctly") {
                expect(try? UInt8(from: [42])).to(equal(42))
            }

            it("throws when deserializing empty data") {
                expect { try UInt8(from: []) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class Int8CodableTest: QuickSpec {
    public override func spec() {
        describe("serializing") {
            it("serializes positive number correctly") {
                expect(Int8(42).directSerialized()).to(equal([42]))
            }

            it("serializes negative number correctly") {
                expect(Int8(-42).directSerialized()).to(equal([0b11010110]))
            }
        }

        describe("deserializing") {
            it("deserializes positive number correctly") {
                expect(try? Int8(from: [42])).to(equal(42))
            }
            it("deserializes negative number correctly") {
                expect(try? Int8(from: [0b11010110])).to(equal(-42))
            }

            it("throws when deserializing empty data") {
                expect { try Int8(from: []) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class UInt64CodableTest: QuickSpec {
    public override func spec() {
        describe("serializing") {
            it("serializes correctly") {
                expect(UInt64(0x0102030405060708).directSerialized()).to(equal(Array(1...8)))
            }
        }

        describe("deserializing") {
            it("deserializes correctly") {
                expect(try? UInt64(from: Array(1...8))).to(equal(0x0102030405060708))
            }

            it("throws when deserializing empty data") {
                expect { try UInt64(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when deserializing short data") {
                expect { try UInt64(from: Array(1...7)) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class DoubleCodableTest: QuickSpec {
    public override func spec() {
        let serializedData: ByteArray = [0b01000000, 0b00110111, 0, 0, 0, 0, 0, 0]
        let deserializedDouble: Double = 23

        describe("serializing") {
            it("serializes correctly") {
                expect(deserializedDouble.directSerialized()).to(equal(serializedData))
            }
        }

        describe("deserializing") {
            it("deserializes correctly") {
                expect(try? Double(from: serializedData)).to(equal(deserializedDouble))
            }

            it("throws when deserializing empty data") {
                expect { try Double(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when deserializing short data") {
                expect { try Double(from: Array(1...7)) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class VarInt32CodableTest: QuickSpec {
    public override func spec() {
        let data: [Int32: ByteArray] = [
            0: [0x00],
            1: [0x01],
            2: [0x02],
            127: [0x7f],
            128: [0x80, 0x01],
            255: [0xff, 0x01],
            2147483647: [0xff, 0xff, 0xff, 0xff, 0x07],
            -1: [0xff, 0xff, 0xff, 0xff, 0x0f],
            -2147483648: [0x80, 0x80, 0x80, 0x80, 0x08]
        ]

        describe("serializing") {
            it("serializes correctly") {
                for (deserializedData, serializedData) in data {
                    let varInt = VarInt32(deserializedData)
                    expect(varInt.directSerialized()).to(equal(serializedData))
                }
            }
        }

        describe("deserializing") {
            context("when deserializing valid data") {
                it("deserializes correctly") {
                    for (deserializedData, serializedData) in data {
                        expect(try? VarInt32(from: serializedData).value).to(equal(deserializedData))
                    }
                }

                it("does not throw") {
                    for (_, serializedData) in data {
                        expect { try VarInt32(from: serializedData) }.toNot(throwError())
                    }
                }
            }

            context("when deserializing to many bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff, 0xff, 0x07]
                    expect { try VarInt32(from: invalidData) }.to(throwError(VarInt32.TypeDeserializeError.varIntToBig))
                }
            }

            context("when deserializing data with missing bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff]
                    expect { try VarInt32(from: invalidData) }.to(throwError(BufferError.noDataAvailable))
                }
            }
        }
    }
}

public class VarInt64CodableTest: QuickSpec {
    public override func spec() {
        let data: [Int64: ByteArray] = [
            0: [0x00],
            1: [0x01],
            2: [0x02],
            127: [0x7f],
            128: [0x80, 0x01],
            255: [0xff, 0x01],
            2147483647: [0xff, 0xff, 0xff, 0xff, 0x07],
            9223372036854775807: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f],
            -1: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01],
            -2147483648: [0x80, 0x80, 0x80, 0x80, 0xf8, 0xff, 0xff, 0xff, 0xff, 0x01],
            -9223372036854775808: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01]
        ]

        describe("serializing") {
            it("serializes correctly") {
                for (deserializedData, serializedData) in data {
                    let varInt = VarInt64(deserializedData)
                    expect(varInt.directSerialized()).to(equal(serializedData))
                }
            }
        }

        describe("deserializing") {
            context("when deserializing valid data") {
                it("deserializes correctly") {
                    for (deserializedData, serializedData) in data {
                        expect(try? VarInt64(from: serializedData).value).to(equal(deserializedData))
                    }
                }

                it("does not throw") {
                    for (_, serializedData) in data {
                        expect { try VarInt64(from: serializedData) }.toNot(throwError())
                    }
                }
            }

            context("when deserializing to many bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f]
                    expect { try VarInt64(from: invalidData) }.to(throwError(VarInt64.TypeDeserializeError.varIntToBig))
                }
            }

            context("when deserializing data with missing bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff]
                    expect { try VarInt64(from: invalidData) }.to(throwError(BufferError.noDataAvailable))
                }
            }
        }
    }
}

public class StringCodableTest: QuickSpec {
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

public class PositionCodableTest: QuickSpec {
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

public class UUIDCodableTest: QuickSpec {
    public override func spec() {
        describe("when creating a uuid") {
            let uuid = UUID()

            it("serialized uuid is 16 bytes long") {
                expect(uuid.directSerialized().count).to(equal(16))
            }

            it("can be serialized and deserialized") {
                print(uuid)
                let serializedUUID = uuid.directSerialized()
                let deserializedUUID = try? UUID(from: serializedUUID)
                expect(deserializedUUID).to(equal(uuid))
            }
        }
    }
}
