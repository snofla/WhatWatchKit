import XCTest
import CoreImage
@testable import WhatWatchKit

final class WhatWatchKitTests: XCTestCase {
    
    func test_Diver() async throws {
        let path = self.imageURL(for: "diver_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .diver)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .diver)
    }
    
    func test_Dress() async throws {
        let path = self.imageURL(for: "dress_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .dress)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .dress)
    }

    func test_Sport() async throws {
        let path = self.imageURL(for: "sport_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .sport)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .sport)
    }

    func test_Chronograph() async throws {
        let path = self.imageURL(for: "chronograph_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .chronograph)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .chronograph)
    }

    func test_Field() async throws {
        let path = self.imageURL(for: "field_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .field)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .field)
    }

    func test_Pilot() async throws {
        let path = self.imageURL(for: "pilot_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .pilot)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .pilot)
    }

    func test_GMT() async throws {
        let path = self.imageURL(for: "gmt_100")
        XCTAssertNotNil(path)
        let results = try await What.categoryOfWatch(at: path!)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .gmt)
        let image = CIImage(contentsOf: path!)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .gmt)
    }

    func imageURL(for name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "Resources")
    }
    
}



extension WhatWatchKitTests {
    
    func test_Whether() async throws {
        let result = try await Whether.anyWatches(at: self.imageURL(for: "diver_100")!)
        print("")
    }
    
    
}
