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

class TCPClientTests: QuickSpec {
    override func spec() {
        it("connects to a valid host") {
            let client = TCPClient(host: "example.com", port: 80)

            waitUntil { done in
                var eventCount = 0
                client.events { event in
                    eventCount += 1

                    switch event {
                    case let .received(data):
                        expect(String(data: data, encoding: .utf8)).toNot(beNil())
                        expect(eventCount).to(equal(5))
                        client.close()
                        done()
                    default:
                        break
                    }
                }

                client.connect()
                client.send(bytes: [0x00, 0x00, 0x00])
            }
        }

        it("does not connect to a invalid host") {
            let client = TCPClient(host: "example.com2", port: 80)

            waitUntil { done in

                client.events { event in
                    client.close()
                    expect(event).to(equal(.unknownError))
                    done()
                }

                client.connect()
            }
        }
    }
}
