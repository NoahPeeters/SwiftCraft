//
//  MinecraftUserLoginTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
import Alamofire
@testable import SwiftCraft

public class MinecraftUserLoginTests: QuickSpec {
    // swiftlint:disable:next function_body_length
    public override func spec() {
        let loginService = UserLoginService()

        context("when using correct credentials") {
            let passwordCredentials = UserLoginPasswordCredentials.readFromEnvironment()

            context("when requesting a user object") {
                var response: Result<UserLoginResponse>?

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

                it("should have an value") {
                    expect(response?.value).toNot(beNil())
                }

                it("should have a non empty access token") {
                    expect(response?.value?.accessToken).toNot(beEmpty())
                }

                it("should have a non empty clientToken token") {
                    expect(response?.value?.clientToken).toNot(beEmpty())
                }

                it("should have a non empty selected profile id") {
                    expect(response?.value?.selectedProfile.id).toNot(beEmpty())
                }

                it("should have a non empty selected profile name") {
                    expect(response?.value?.selectedProfile.name).toNot(beEmpty())
                }

                it("should have the selected profile in the available profiles array") {
                    expect(response?.value?.availableProfiles).to(contain(response?.value?.selectedProfile))
                }

                it("should have an user object") {
                    expect(response?.value?.user).toNot(beNil())
                }

                it("should have a non empty user id") {
                    expect(response?.value?.user?.id).toNot(beEmpty())
                }

                it("should not have an value") {
                    expect(response?.error).to(beNil())
                }

                context("when refreshing the session") {
                    var refreshResponse: Result<UserLoginResponse>?

                    beforeOnce {
                        if let originalResponse = response?.value {
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
                        expect(refreshResponse?.value?.clientToken).to(equal(response?.value?.clientToken))
                    }

                    it("should have a new access token") {
                        expect(refreshResponse?.value?.accessToken).toNot(equal(response?.value?.accessToken))
                    }

                    it("should not contain available profiles") {
                        expect(refreshResponse?.value?.availableProfiles).to(beNil())
                    }

                    it("should contain the same user") {
                        expect(refreshResponse?.value?.user).to(equal(response?.value?.user))
                    }

                    it("should contain the same selected profile") {
                        expect(refreshResponse?.value?.selectedProfile).to(equal(response?.value?.selectedProfile))
                    }
                }
            }

            context("when not requesting a user object") {
                var response: Result<UserLoginResponse>?

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
                    expect(response?.value?.user).to(beNil())
                }
            }
        }

        context("when using incorrect credentials") {
            let passwordCredentials = UserLoginPasswordCredentials(
                username: "invalidmail@example.com",
                password: "invalid password")

            var response: Result<UserLoginResponse>?

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

            it("should not have an value") {
                expect(response?.value).to(beNil())
            }

            it("should have an error") {
                expect(response?.error).toNot(beNil())
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
