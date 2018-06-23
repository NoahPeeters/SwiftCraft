//
//  TCPClientTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class TCPClientTests: QuickSpec {
    public override func spec() {
        it("connects to a valid host") {
            let client = TCPClient(host: "example.com", port: 80)

            waitUntil { done in
                client.events { event in
                    switch event {
                    case let .received(data):
                        expect(String(data: data, encoding: .utf8)).toNot(beNil())
                        client.close()
                        done()
                    default:
                        break
                    }
                }

                expect(client.connect()).to(equal(true))
                expect { try client.send(bytes: [0x00, 0x00, 0x00]) }.toNot(throwError())
            }
        }

        it("does not connect to a invalid host") {
            let client = TCPClient(host: "example.com2", port: 80)
            expect(client.connect()).to(equal(false))
        }
    }
}
