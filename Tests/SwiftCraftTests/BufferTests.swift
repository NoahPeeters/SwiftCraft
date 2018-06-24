//
//  BufferTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

public class ReadBufferTests: QuickSpec {
    //swiftlint:disable:next function_body_length
    public override func spec() {
        describe("creating a buffer with data") {
            var buffer: ByteBuffer!

            beforeEach {
                buffer = ByteBuffer(elements: Array(0..<42))
            }

            it("contains remaining data") {
                expect(buffer.remainingData()).to(equal(42))
            }

            it("reads one byte without throwing an exception") {
                expect { try buffer.readOne() }.toNot(throwError())
            }

            it("reads one byte correctly") {
                expect(try? buffer.readOne()).to(equal(0))
            }

            it("reads multiple bytes without throwing an exception") {
                expect { try buffer.read(lenght: 10) }.toNot(throwError())
            }

            it("reads multiple bytes correctly") {
                expect(try? buffer.read(lenght: 10)).to(equal(Array(0..<10)))
            }

            it("reads all remaining bytes without throwing an exception") {
                expect { try buffer.read(lenght: buffer.remainingData()) }.toNot(throwError())
            }

            it("reads all remaining bytes correctly") {
                expect(buffer.readRemainingElements()).to(equal(Array(0..<42)))
            }

            it("reading one throws after reading to many bytes") {
                expect { try buffer.read(lenght: buffer.remainingData()) }.toNot(throwError())
                expect { try buffer.readOne() }.to(throwError(BufferError.noDataAvailable))
            }

            it("reading multiple throws after reading to many bytes") {
                expect { try buffer.read(lenght: buffer.remainingData()) }.toNot(throwError())
                expect { try buffer.read(lenght: 10) }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws an error when reading to many bytes") {
                expect { try buffer.read(lenght: 50) }.to(throwError(BufferError.noDataAvailable))
            }

            context("when clearing the buffer") {
                beforeEach {
                    buffer.clear()
                }

                it("is empty") {
                    expect(buffer.remainingData()).to(equal(0))
                }
            }

            describe("when reading 10 elements") {
                beforeEach {
                    _ = try? buffer.read(lenght: 10)
                }

                describe("when resetting the read position") {
                    beforeEach {
                        buffer.resetPosition()
                    }

                    it("reads the correct element") {
                        expect(try? buffer.readOne()).to(equal(0))
                    }

                    it("has the correct length") {
                        expect(buffer.remainingData()).to(equal(42))
                    }
                }

                describe("when dropping read elements") {
                    beforeEach {
                        buffer.dropReadElements()
                    }

                    it("reads the correct element") {
                        expect(try? buffer.readOne()).to(equal(10))
                    }

                    it("has the correct length") {
                        expect(buffer.remainingData()).to(equal(32))
                    }
                }
            }

            context("when accessing the data as unsafe buffer") {
                var readData: ByteArray = []

                beforeEach {
                    readData = buffer.withUnsafePointer { (pointer: UnsafePointer<Byte>) -> ByteArray in
                        let buffer = UnsafeBufferPointer(start: pointer, count: 10)
                        return Array(buffer)
                    }
                }

                it("accesses the correct data") {
                    expect(readData).to(equal(Array(0..<10)))
                }

                it("does not change the read position") {
                    expect(buffer.position).to(equal(0))
                }
            }

            context("when loading the data as other type") {
                it("updates the read position correctly when reading UInt8") {
                    let _: UInt8? = try? buffer.loadAsType()
                    expect(buffer.position).to(equal(1))
                }

                it("updates the read position correctly when reading UInt64") {
                    let _: UInt64? = try? buffer.loadAsType()
                    expect(buffer.position).to(equal(8))
                }

                it("does not throw an error") {
                    expect { () -> UInt8 in
                        try buffer.loadAsType()
                    }.toNot(throwError())
                }
            }
        }

        describe("creating a buffer without data") {
            var buffer: ByteBuffer!

            beforeEach {
                buffer = ByteBuffer()
            }

            it("throws when reading one byte") {
                expect { try buffer.readOne() }.to(throwError(BufferError.noDataAvailable))
            }

            it("throws when reading multiple byte") {
                expect { try buffer.read(lenght: 50) }.to(throwError(BufferError.noDataAvailable))
            }
        }
    }
}

public class WriteBufferTests: QuickSpec {
    public override func spec() {
        describe("creating a buffer without data") {
            var buffer: ByteBuffer!

            beforeEach {
                buffer = ByteBuffer()
            }

            context("when writing one byte") {
                beforeEach {
                    buffer.write(element: 42)
                }

                it("contains one byte") {
                    expect(buffer.remainingData()).to(equal(1))
                }

                it("contains the correct data") {
                    expect(try? buffer.readOne()).to(equal(42))
                }
            }

            context("when writing multiple bytes") {
                beforeEach {
                    buffer.write(elements: Array(0..<42))
                }

                it("contains the correct number of bytes") {
                    expect(buffer.remainingData()).to(equal(42))
                }

                it("contains the correct data") {
                    expect(try? buffer.read(lenght: 42)).to(equal(Array(0..<42)))
                }
            }
        }
    }
}
