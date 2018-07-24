//
//  TabCompleteResponsePacketTests.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 24.07.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

public class TabCompleteResponsePacketTests: QuickSpec {
    public override func spec() {
        context("checking with protocol version 340") {
            describe("deserializing") {
                var packet: TabCompleteResponsePacket?

                beforeEach {
                    packet = try? TabCompleteResponsePacket(
                        from: [
                            2,
                            5, 0x48, 0x65, 0x6C, 0x6C, 0x6F,
                            5, 0x57, 0x6F, 0x72, 0x6C, 0x64
                        ],
                        context: MockSerializationContext.play340)
                }

                it("succeds") {
                    expect(packet).toNot(beNil())
                }

                it("has the correct message") {
                    let message = packet?.completions
                    expect(message).to(equal(["Hello", "World"]))
                }
            }

            it("has the correct packet id") {
                expect(TabCompleteResponsePacket.packetID(context: MockSerializationContext.play340))
                    .to(equal(PacketID(connectionState: .play, id: 0x0E)))
            }
        }
    }
}
