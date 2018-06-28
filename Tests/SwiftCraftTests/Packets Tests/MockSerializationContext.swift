//
//  MockSerializationContext.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftCraft

public struct MockSerializationContext: SerializationContext {
    public var connectionState: ConnectionState

    public var protocolVersion: Int

    public var dimension: SwiftCraft.Dimension

    public init(protocolVersion: Int,
                connectionState: ConnectionState = .play,
                dimension: SwiftCraft.Dimension = .overworld) {
        self.connectionState = connectionState
        self.protocolVersion = protocolVersion
        self.dimension = dimension
    }

    public static let play340: MockSerializationContext = MockSerializationContext(protocolVersion: 340)
}

public class MockSerializationContextTests: QuickSpec {
    public override func spec() {
        context("when getting the default play430 context") {
            var context: MockSerializationContext!

            beforeEach {
                context = .play340
            }

            it("has the correct protocol version") {
                expect(context.protocolVersion).to(equal(340))
            }

            it("has the correct dimension") {
                expect(context.dimension).to(equal(.overworld))
            }

            it("has the correct connection state") {
                expect(context.connectionState).to(equal(.play))
            }
        }
    }
}
