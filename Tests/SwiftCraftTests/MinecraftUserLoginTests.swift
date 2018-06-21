//
//  MinecraftUserLoginTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class MinecraftUserLoginTests: QuickSpec {
    // swiftlint:disable:next function_body_length
    public override func spec() {
        let loginService = UserLoginService()

        context("when using correct credentials") {
            let passwordCredentials = UserLoginPasswordCredentials.readFromEnvironment()

            context("when requesting a user object") {
                var response: UserLoginResponse?

                beforeOnce {
                    waitUntil(timeout: 10) { done in
                        loginService.login(credentials: passwordCredentials, requestUser: true) {
                            response = $0
                            done()
                        }
                    }
                }

                fit("should not be nil") {
                    expect(response).toNot(beNil())
                }

                it("should have a non empty access token") {
                    expect(response?.accessToken).toNot(beEmpty())
                }

                it("should have a non empty clientToken token") {
                    expect(response?.clientToken).toNot(beEmpty())
                }

                it("should have a non empty selected profile id") {
                    expect(response?.selectedProfile.id).toNot(beEmpty())
                }

                it("should have a non empty selected profile name") {
                    expect(response?.selectedProfile.name).toNot(beEmpty())
                }

                it("should have the selected profile in the available profiles array") {
                    expect(response?.availableProfiles).to(contain(response?.selectedProfile))
                }

                it("should have an user object") {
                    expect(response?.user).toNot(beNil())
                }

                it("should have a non empty user id") {
                    expect(response?.user?.id).toNot(beEmpty())
                }

                context("when refreshing the session") {
                    var refreshResponse: UserLoginResponse?

                    beforeOnce {
                        if let originalResponse = response {
                            waitUntil {done in
                                loginService.login(credentials: originalResponse, requestUser: true) {
                                    refreshResponse = $0
                                    done()
                                }
                            }
                        }
                    }

                    it("should not be nil") {
                        expect(refreshResponse).toNot(beNil())
                    }

                    it("should have the same client token") {
                        expect(refreshResponse?.clientToken).to(equal(response?.clientToken))
                    }

                    it("should have a new access token") {
                        expect(refreshResponse?.accessToken).toNot(equal(response?.accessToken))
                    }

                    it("should not contain available profiles") {
                        expect(refreshResponse?.availableProfiles).to(beNil())
                    }

                    it("should contain the same user") {
                        expect(refreshResponse?.user).to(equal(response?.user))
                    }

                    it("should contain the same selected profile") {
                        expect(refreshResponse?.selectedProfile).to(equal(response?.selectedProfile))
                    }
                }
            }

            context("when not requesting a user object") {
                var response: UserLoginResponse?

                beforeOnce {
                    waitUntil { done in
                        loginService.login(credentials: passwordCredentials, requestUser: false) {
                            response = $0
                            done()
                        }
                    }
                }

                it("should not be nil") {
                    expect(response).toNot(beNil())
                }

                it("should not have an user object") {
                    expect(response?.user).to(beNil())
                }
            }
        }

        context("when using incorrect credentials") {
            let passwordCredentials = UserLoginPasswordCredentials(
                username: "invalidmail@example.com",
                password: "invalid password")

            var response: UserLoginResponse?

            beforeOnce {
                waitUntil { done in
                    loginService.login(credentials: passwordCredentials, requestUser: true) {
                        response = $0
                        done()
                    }
                }
            }

            it("should not be nil") {
                expect(response).toNot(beNil())
            }
        }
    }
}

extension UserLoginPasswordCredentials {
    /// Creates new credentials by reading the username and password from the environment variables
    /// `username` and `password`.
    ///
    /// - Returns: The credentials.
    public static func readFromEnvironment() -> UserLoginPasswordCredentials {
        return UserLoginPasswordCredentials(
            username: ProcessInfo.processInfo.environment["username"]!,
            password: ProcessInfo.processInfo.environment["password"]!
        )
    }
}
