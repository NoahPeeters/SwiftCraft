//
//  NumberSerializationTests.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 25.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class BoolSerializationTests: QuickSpec {
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

public class UInt8SerializationTests: QuickSpec {
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

public class Int8SerializationTests: QuickSpec {
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

public class UInt64SerializationTests: QuickSpec {
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

public class FloatSerializationTests: QuickSpec {
    public override func spec() {
        let serializedData: ByteArray = [0b01000001, 0b10111000, 0, 0]
        let deserializedFloat: Float = 23

        describe("serializing") {
            it("serializes correctly") {
                expect(deserializedFloat.directSerialized()).to(equal(serializedData))
            }
        }

        describe("deserializing") {
            it("deserializes correctly") {
                expect(try? Float(from: serializedData)).to(equal(deserializedFloat))
            }

            it("throws when deserializing empty data") {
                expect { try Float(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when deserializing short data") {
                expect { try Float(from: Array(1...3)) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class DoubleSerializationTests: QuickSpec {
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

public class VarInt32SerializationTests: QuickSpec {
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

public class VarInt64SerializationTests: QuickSpec {
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
