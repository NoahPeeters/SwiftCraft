//
//  UserLoginResponse.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The response of a successfull user login.
public struct UserLoginResponse: UserLoginSessionCredentials, Codable, Equatable {
    /// A profile of the user.
    public struct Profile: Codable, Hashable {
        /// The id of the profile.
        public let id: String

        /// The username of the profile.
        public let name: String
    }

    /// User object in the response
    public struct User: Codable, Equatable {
        /// The id of the user.
        public let id: String

        /// List of properties.
        public let properties: [UserProperty]?
    }

    /// Property of a user.
    public struct UserProperty: Codable, Hashable {
        /// The name of the property.
        let name: String

        /// The value of the property.
        let value: String
    }

    /// The access token returned from the server.
    public let accessToken: String

    /// The client token returned from the server.
    public let clientToken: String

    /// The current selected profile.
    public let selectedProfile: Profile

    /// A list of all profile.
    public let availableProfiles: [Profile]?

    /// A optional user object. This will be include if the request requested it.
    public let user: User?
}

extension UserLoginResponse: AuthenticationProvider {
    public var profileID: String {
        return selectedProfile.id
    }

    public var username: String {
        return selectedProfile.name
    }
}
