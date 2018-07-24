//
//  TabCompleteRequestPacketTests.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 24.07.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

public class TabCompleteRequestPacketTests: QuickSpec {
    public override func spec() {
        context("checking with protocol version 340") {
            describe("serializing") {
                var packetData: ByteArray?

                beforeEach {
                    let packet = TabCompleteRequestPacket(text: "/hello", assumeCommand: true, position: nil)
                    packetData = packet.serializedData(context: MockSerializationContext.play340)
                }

                it("has the correct content") {
                    expect(packetData).to(equal([6, 0x2F, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 1, 0]))
                }
            }

            it("has the correct packet id") {
                expect(TabCompleteRequestPacket.packetID(context: MockSerializationContext.play340))
                    .to(equal(PacketID(connectionState: .play, id: 0x01)))
            }
        }
    }
}
