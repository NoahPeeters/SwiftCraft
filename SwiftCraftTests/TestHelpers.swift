//
//  TestHelpers.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick

extension QuickSpec {
    public func beforeOnce(_ closure: @escaping BeforeExampleClosure) {
        var isFirst = true

        beforeEach {
            guard isFirst else {
                return
            }
            isFirst = false
            closure()
        }
    }
}
