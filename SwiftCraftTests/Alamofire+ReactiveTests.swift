//
//  Alamofire+ReactiveTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
import Result
import Alamofire
import ReactiveSwift
import enum Result.Result
@testable import SwiftCraft

class AlamofireReactiveTests: QuickSpec {
    override func spec() {
        context("when starting a valid request") {
            var result: Result<Data, AnyError>?

            beforeOnce {
                result = Alamofire.request("http://httpbin.org/json").signalProducer().single()
            }

            it("should not be nil") {
                expect(result).toNot(beNil())
            }

            it("should have an value") {
                expect(result?.value).toNot(beNil())
            }

            it("should not have an value") {
                expect(result?.error).to(beNil())
            }
        }

        context("when starting a valid string") {
            var result: Result<String?, AnyError>?

            beforeOnce {
                result = Alamofire.request("http://httpbin.org/robots.txt").stringSignalProducer().single()
            }

            it("should not be nil") {
                expect(result).toNot(beNil())
            }

            it("should have an value") {
                expect(result?.value).toNot(beNil())
            }

            it("should have the correct string value") {
                expect(result?.value).to(equal("User-agent: *\nDisallow: /deny\n"))
            }

            it("should not have an value") {
                expect(result?.error).to(beNil())
            }
        }

        context("when starting an invalid request") {
            var result: Result<Data, AnyError>?

            beforeOnce {
                result = Alamofire.request("http://httpbin2.org/json").signalProducer().single()
            }

            it("should not be nil") {
                expect(result).toNot(beNil())
            }

            it("should not have an value") {
                expect(result?.value).to(beNil())
            }

            it("should have an error") {
                expect(result?.error).toNot(beNil())
            }
        }
    }
}
