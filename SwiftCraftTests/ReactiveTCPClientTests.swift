//
//  ReactiveTCPClientTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
import Result
@testable import SwiftCraft

class ReactiveTCPClientTests: QuickSpec {
    override func spec() {
        it("connects to a valid host") {
            let client = ReactiveTCPClient(host: "example.com", port: 80)

            waitUntil { done in
                var eventCount = 0
                client.events.observeResult { event in
                    eventCount += 1

                    switch event.value! {
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
                client.output.send(value: [0x00, 0x00, 0x00])
            }
        }

        it("does not connect to a invalid host") {
            let client = ReactiveTCPClient(host: "example.com2", port: 80)

            waitUntil { done in
                client.events.observeResult { event in
                    client.close()
                    expect(event.error).to(matchError(TCPClientError.unknownError))
                    done()
                }

                client.connect()
            }
        }
    }
}
