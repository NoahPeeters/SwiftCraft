//
//  TranslationTests.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 25.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

public class TranslationTests: QuickSpec {
    // swiftlint:disable:next function_body_length
    public override func spec() {
        context("when using an invalid key") {
            it("returns the key") {
                expect(EnglishTranslationManager().string(
                    withKey: "invalidKey",
                    substitutions: [])
                ).to(equal("invalidKey"))
            }
        }
        context("when using an valid key") {
            context("when not expecting substitutions") {
                it("returns the raw translation when not providing substitutions") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.none",
                        substitutions: [])
                    ).to(equal("Hello, world!"))
                }

                it("returns the raw translation when providing substitutions") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.none",
                        substitutions: ["This", "is", "a", "test"])
                    ).to(equal("Hello, world!"))
                }
            }

            context("when expecting simple substitutions") {
                it("returns the raw translation when not providing substitutions") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.args",
                        substitutions: [])
                    ).to(equal("%s %s"))
                }

                it("returns the substituted translation when providing substitutions") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.args",
                        substitutions: ["This", "is"])
                    ).to(equal("This is"))
                }
            }

            context("when expecting complex substitutions") {
                it("returns the raw translation when not providing substitutions") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.complex",
                        substitutions: [])
                    ).to(equal("Prefix, %s%2$s again %s and %1$s lastly %s and also %1$s again!"))
                }

                it("returns the substituted translation when providing substitutions") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.complex",
                        substitutions: ["Text1", "Text2", "Text3"])
                    ).to(equal("Prefix, Text1Text2 again Text2 and Text1 lastly Text3 and also Text1 again!"))
                }
            }

            context("when expecting complex substitutions") {
                it("returns the correct text") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.escape",
                        substitutions: ["1", "2"])
                    ).to(equal("%s %1 %%s %%2"))
                }
            }

            context("when parsing an invalid string") {
                it("can parse an open percentage") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.invalid",
                        substitutions: ["1", "2"])
                    ).to(equal("hi %"))
                }

                it("can parse an open number") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.invalid2",
                        substitutions: ["1", "2"])
                    ).to(equal("hi %1"))
                }

                it("can parse an invalid number") {
                    expect(EnglishTranslationManager().string(
                        withKey: "translation.test.invalid3",
                        substitutions: ["1"])
                    ).to(equal("hi %d$s world"))
                }
            }
        }
    }
}
