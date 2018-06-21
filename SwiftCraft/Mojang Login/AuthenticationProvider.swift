//
//  AuthenticationProvider.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Provides the nessesary data for the session server service.
public protocol AuthenticationProvider {
    /// The access token received from the server
    var accessToken: String { get }

    /// The uuid of the selected profile
    var profileID: String { get }

    /// The username of the selected profile
    var username: String { get }
}
