//
//  DisconnectPlayPacketTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

public class DisconnectPlayPacketTests: QuickSpec {
    public override func spec() {
        context("checking with protocol version 340") {
            describe("deserializing") {
                var packet: DisconnectPlayPacket?

                beforeEach {
                    packet = try? DisconnectPlayPacket(
                        from: [
                            16, 0x7b, 0x22, 0x74, 0x65, 0x78,
                            0x74, 0x22, 0x3a, 0x22, 0x48, 0x65,
                            0x6c, 0x6c, 0x6f, 0x22, 0x7d
                        ],
                        context: MockSerializationContext.play340)
                }

                it("succeds") {
                    expect(packet).toNot(beNil())
                }

                it("has the correct message") {
                    let message = packet?.message.message.string(translationManager: EnglishTranslationManager())
                    expect(message).to(equal("Hello"))
                }
            }

            it("has the correct packet id") {
                expect(DisconnectPlayPacket.packetID(context: MockSerializationContext.play340))
                    .to(equal(PacketID(connectionState: .play, id: 0x1A)))
            }
        }
    }
}
