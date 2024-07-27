import XCTest
@testable import WhatWatchKit

final class WhatWatchKitTests: XCTestCase {
    
    func test_Diver() async throws {
        let path = self.imageURL(for: "diver_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .diver)
    }
    
    func test_Dress() async throws {
        let path = self.imageURL(for: "dress_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .dress)
    }

    func test_Sport() async throws {
        let path = self.imageURL(for: "sport_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .sport)
    }

    func test_Chronograph() async throws {
        let path = self.imageURL(for: "chronograph_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .chronograph)
    }

    func test_Field() async throws {
        let path = self.imageURL(for: "field_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .field)
    }

    func test_Pilot() async throws {
        let path = self.imageURL(for: "pilot_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .pilot)
    }

    func test_GMT() async throws {
        let path = self.imageURL(for: "gmt_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .gmt)
    }

    func imageURL(for name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "Resources")
    }
    
}
