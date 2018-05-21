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

class BoolCodableTests: QuickSpec {
    override func spec() {
        describe("encoding") {
            it("encodes false") {
                expect(false.directEncode()).to(equal([0]))
            }

            it("encodes true") {
                expect(true.directEncode()).to(equal([1]))
            }
        }

        describe("decoding") {
            it("decodes false") {
                expect(try? Bool(from: [0])).to(equal(false))
            }

            it("decodes true") {
                expect(try? Bool(from: [1])).to(equal(true))
            }

            it("throws when decoding empty data") {
                expect { try Bool(from: []) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

class UInt8CodableTest: QuickSpec {
    override func spec() {
        describe("encoding") {
            it("encodes correctly") {
                expect(UInt8(42).directEncode()).to(equal([42]))
            }
        }

        describe("decoding") {
            it("decodes correctly") {
                expect(try? UInt8(from: [42])).to(equal(42))
            }

            it("throws when decoding empty data") {
                expect { try UInt8(from: []) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

class Int8CodableTest: QuickSpec {
    override func spec() {
        describe("encoding") {
            it("encodes positive number correctly") {
                expect(Int8(42).directEncode()).to(equal([42]))
            }

            it("encodes negative number correctly") {
                expect(Int8(-42).directEncode()).to(equal([0b11010110]))
            }
        }

        describe("decoding") {
            it("decodes positive number correctly") {
                expect(try? Int8(from: [42])).to(equal(42))
            }
            it("decodes negative number correctly") {
                expect(try? Int8(from: [0b11010110])).to(equal(-42))
            }

            it("throws when decoding empty data") {
                expect { try Int8(from: []) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

class UInt64CodableTest: QuickSpec {
    override func spec() {
        describe("encoding") {
            it("encodes correctly") {
                expect(UInt64(0x0102030405060708).directEncode()).to(equal(Array(1...8)))
            }
        }

        describe("decoding") {
            it("decodes correctly") {
                expect(try? UInt64(from: Array(1...8))).to(equal(0x0102030405060708))
            }

            it("throws when decoding empty data") {
                expect { try UInt64(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when decoding short data") {
                expect { try UInt64(from: Array(1...7)) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

class DoubleCodableTest: QuickSpec {
    override func spec() {
        let encodedData: ByteArray = [0b01000000, 0b00110111, 0, 0, 0, 0, 0, 0]
        let decodedDouble: Double = 23

        describe("encoding") {
            it("encodes correctly") {
                expect(decodedDouble.directEncode()).to(equal(encodedData))
            }
        }

        describe("decoding") {
            it("decodes correctly") {
                expect(try? Double(from: encodedData)).to(equal(decodedDouble))
            }

            it("throws when decoding empty data") {
                expect { try Double(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when decoding short data") {
                expect { try Double(from: Array(1...7)) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

class VarInt32CodableTest: QuickSpec {
    override func spec() {
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

        describe("encoding") {
            it("encodes correctly") {
                for (decodedData, encodedData) in data {
                    let varInt = VarInt32(decodedData)
                    expect(varInt.directEncode()).to(equal(encodedData))
                }
            }
        }

        describe("decoding") {
            context("when decoding valid data") {
                it("decodes correctly") {
                    for (decodedData, encodedData) in data {
                        expect(try? VarInt32(from: encodedData).value).to(equal(decodedData))
                    }
                }

                it("does not throw") {
                    for (_, encodedData) in data {
                        expect { try VarInt32(from: encodedData) }.toNot(throwError())
                    }
                }
            }

            context("when decoding to many bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff, 0xff, 0x07]
                    expect { try VarInt32(from: invalidData) }.to(throwError(TypeDecodeError.varIntToBig))
                }
            }

            context("when decoding data with missing bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff]
                    expect { try VarInt32(from: invalidData) }.to(throwError(BufferError.noDataAvailable))
                }
            }
        }
    }
}

class VarInt64CodableTest: QuickSpec {
    override func spec() {
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

        describe("encoding") {
            it("encodes correctly") {
                for (decodedData, encodedData) in data {
                    let varInt = VarInt64(decodedData)
                    expect(varInt.directEncode()).to(equal(encodedData))
                }
            }
        }

        describe("decoding") {
            context("when decoding valid data") {
                it("decodes correctly") {
                    for (decodedData, encodedData) in data {
                        expect(try? VarInt64(from: encodedData).value).to(equal(decodedData))
                    }
                }

                it("does not throw") {
                    for (_, encodedData) in data {
                        expect { try VarInt64(from: encodedData) }.toNot(throwError())
                    }
                }
            }

            context("when decoding to many bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f]
                    expect { try VarInt64(from: invalidData) }.to(throwError(TypeDecodeError.varIntToBig))
                }
            }

            context("when decoding data with missing bytes") {
                it("throws") {
                    let invalidData: ByteArray = [0xff, 0xff, 0xff, 0xff]
                    expect { try VarInt64(from: invalidData) }.to(throwError(BufferError.noDataAvailable))
                }
            }
        }
    }
}

class StringCodableTest: QuickSpec {
    override func spec() {

        describe("ascii") {
            let encodedData: ByteArray = [12, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21]
            let decodedStrign = "Hello World!"

            describe("encoding") {
                it("encodes correctly") {
                    expect(decodedStrign.directEncode()).to(equal(encodedData))
                }
            }

            describe("decoding") {
                it("decodes correctly") {
                    expect(try? String(from: encodedData)).to(equal(decodedStrign))
                }
            }
        }

        describe("emoji") {
            let encodedData: ByteArray = [4, 0xf0, 0x9f, 0x98, 0x8e]
            let decodedString = "😎"

            describe("encoding") {
                it("encodes correctly") {
                    expect(decodedString.directEncode()).to(equal(encodedData))
                }
            }

            describe("decoding") {
                it("decodes correctly") {
                    expect(try? String(from: encodedData)).to(equal(decodedString))
                }
            }
        }

        describe("empty string") {
            describe("encoding") {
                it("encodes correctly") {
                    expect("".directEncode()).to(equal([0]))
                }
            }

            describe("decoding") {
                it("decodes correctly") {
                    expect(try? String(from: [0])).to(equal(""))
                }
            }
        }

        describe("decoding invalid data") {
            it("throws when decoding empty data") {
                expect { try String(from: []) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when length is longer then the remaining data") {
                expect { try String(from: [5, 42, 42]) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when the data is not valid utf8") {
                expect {
                    try String(from: [3, 0xf0, 0x9f, 0x98])
                }.to(throwError(TypeDecodeError.invalidStringData))
            }
        }
    }
}

class PositionCodableTest: QuickSpec {
    override func spec() {
        describe("zero position") {
            let encodedData: ByteArray = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            let decodedPosition = Position(x: 0, y: 0, z: 0)

            describe("encoding") {
                it("encodes correctly") {
                    expect(decodedPosition.directEncode()).to(equal(encodedData))
                }
            }

            describe("decoding") {
                it("decodes correctly") {
                    expect(try? Position(from: encodedData)).to(equal(decodedPosition))
                }
            }
        }

        describe("positive position") {
            let encodedData: ByteArray = [0x00, 0x00, 0x0a, 0x80, 0xac, 0x00, 0x00, 0x2c]
            let decodedPosition = Position(x: 42, y: 43, z: 44)

            describe("encoding") {
                it("encodes correctly") {
                    expect(decodedPosition.directEncode()).to(equal(encodedData))
                }
            }

            describe("decoding") {
                it("decodes correctly") {
                    expect(try? Position(from: encodedData)).to(equal(decodedPosition))
                }
            }
        }

        describe("negative position") {
            let encodedData: ByteArray = [0xff, 0xff, 0xf5, 0x80, 0x03, 0xff, 0xff, 0xd4]
            let decodedPosition = Position(x: -42, y: 0, z: -44)

            describe("encoding") {
                it("encodes correctly") {
                    expect(decodedPosition.directEncode()).to(equal(encodedData))
                }
            }

            describe("decoding") {
                it("decodes correctly") {
                    expect(try? Position(from: encodedData)).to(equal(decodedPosition))
                }
            }
        }
    }
}
