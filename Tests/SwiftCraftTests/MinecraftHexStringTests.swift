//
//  MinecraftHexStringTests.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 24.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class MinecraftHexStringTests: QuickSpec {
    public override func spec() {
        it("produces the correct hex string for sha1(Notch)") {
            let data = Data(
                bytes: [78, 209, 244, 107, 190, 4, 188, 117, 107, 203, 23, 192, 199, 206, 62, 70, 50, 240, 106, 72])
            expect(data.minecraftHexString()).to(equal("4ED1F46BBE04BC756BCB17C0C7CE3E4632F06A48"))
        }

        it("produces the correct hex string for sha1(jeb_)") {
            let data = Data(
                bytes: [131, 98, 164, 255, 187, 62, 207, 239, 101, 162, 132, 160, 74, 60, 232, 63, 212, 177, 215, 63])
            expect(data.minecraftHexString()).to(equal("-7C9D5B0044C130109A5D7B5FB5C317C02B4E28C1"))
        }

        it("produces the correct hex string for sha1(simon)") {
            let data = Data(
                bytes: [8, 142, 22, 161, 1, 146, 119, 177, 93, 88, 250, 240, 84, 30, 17, 145, 14, 183, 86, 246])
            expect(data.minecraftHexString()).to(equal("88E16A1019277B15D58FAF0541E11910EB756F6"))
        }
    }
}
