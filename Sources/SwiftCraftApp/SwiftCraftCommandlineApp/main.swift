//
//  main.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftCraftAppShared

private let game = SwiftCraftAppGame()

game.startOffline()
RunLoop.current.run()
