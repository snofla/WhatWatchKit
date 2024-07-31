//
//  WhatWatchKitNetworkTests.swift
//  
//
//  Created by Alfons Hoogervorst on 29/07/2024.
//

import XCTest
import CoreImage
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import WhatWatchKit


final class WhatWatchKitNetworkTests: XCTestCase {
    
    class override func setUp() {
        HTTPStubs.setEnabled(true)
    }
    
    class override func tearDown() {
        HTTPStubs.removeAllStubs()
        HTTPStubs.setEnabled(false)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        HTTPStubs.removeAllStubs()
    }

}


extension WhatWatchKitNetworkTests {
    
    func test_What_Diver_Good() async throws {
        self.addGoodStub(for: "diver_100")
        let path = self.imageURL(for: "diver_100")
        let results = try await What.categoryOfWatch(at: path)
        XCTAssert(results.count > 1)
        XCTAssert(results.first!.label == .diver)
        let image = CIImage(contentsOf: path)!
        let results1 = try await What.categoryOfWatch(in: image)
        XCTAssert(results1.count > 1)
        XCTAssert(results1.first!.label == .diver)
    }

    func test_What_Diver_Server_Error() async throws {
        self.addServerErrorStub(for: "diver_100")
        let path = self.imageURL(for: "diver_100")
        let failure = expectation(description: "Should fail")
        do {
            let _ = try await What.categoryOfWatch(at: path)
            XCTFail("Should have failed")
        } catch {
            failure.fulfill()
        }
        await fulfillment(of: [failure], timeout: 1)
    }

    func test_What_Diver_Client_Error() async throws {
        self.addClientErrorStub(for: "diver_100")
        let path = self.imageURL(for: "diver_100")
        let failure = expectation(description: "Should fail")
        do {
            let _ = try await What.categoryOfWatch(at: path)
            XCTFail("Should have failed")
        } catch {
            failure.fulfill()
        }
        await fulfillment(of: [failure], timeout: 1)
    }

    func test_What_Diver_Server_Junk_Error() async throws {
        self.addServerReturningJunkStub(for: "diver_100")
        let path = self.imageURL(for: "diver_100")
        let failure = expectation(description: "Should fail")
        do {
            let _ = try await What.categoryOfWatch(at: path)
            XCTFail("Should have failed")
        } catch {
            failure.fulfill()
        }
        await fulfillment(of: [failure], timeout: 1)
    }

}


extension WhatWatchKitNetworkTests {
    
    func test_Whether_Any_Watches_Good() async throws {
        self.addGoodStub(for: "all_sport")
        let path = self.imageURL(for: "all_sport")
        let result = try await Whether.anyWatches(in: path)
        XCTAssertTrue(result.count == 7, "Should have 7 watches, got \(result.count)")
    }
    
    func test_Whether_Any_Watches_Server_Error() async throws {
        self.addServerErrorStub(for: "all_sport")
        let path = self.imageURL(for: "all_sport")
        let failure = expectation(description: "Should fail")
        do {
            _ = try await Whether.anyWatches(in: path)
            XCTFail("This should fail")
        } catch {
            failure.fulfill()
        }
        await fulfillment(of: [failure], timeout: 1)
    }

    func test_Whether_Any_Watches_Client_Error() async throws {
        self.addClientErrorStub(for: "all_sport")
        let path = self.imageURL(for: "all_sport")
        let failure = expectation(description: "Should fail")
        do {
            _ = try await Whether.anyWatches(in: path)
            XCTFail("This should fail")
        } catch {
            failure.fulfill()
        }
        await fulfillment(of: [failure], timeout: 1)
    }

    func test_Whether_Any_Watches_Server_Junk_Error() async throws {
        self.addServerReturningJunkStub(for: "all_sport")
        let path = self.imageURL(for: "all_sport")
        let failure = expectation(description: "Should fail")
        do {
            _ = try await Whether.anyWatches(in: path)
            XCTFail("This should fail")
        } catch {
            failure.fulfill()
        }
        await fulfillment(of: [failure], timeout: 1)
    }

}

extension WhatWatchKitNetworkTests {
    
    func addGoodStub(for image: String) {
        stub(condition: pathEndsWith(image), response: { (request) -> HTTPStubsResponse in
            let url = Bundle.module.url(forResource: image, withExtension: "png")!
            return .init(fileURL: url, statusCode: 200, headers: nil)
        })
    }
    
    func addServerErrorStub(for image: String) {
        stub(condition: pathEndsWith(image), response: { (request) -> HTTPStubsResponse in
            return .init(data: Data(), statusCode: 500, headers: nil)
        })
    }
    
    func addClientErrorStub(for image: String) {
        stub(condition: pathEndsWith(image), response: { (request) -> HTTPStubsResponse in
            return .init(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil))
        })
    }
    
    func addServerReturningJunkStub(for image: String) {
        stub(condition: pathEndsWith(image), response: { (request) -> HTTPStubsResponse in
            // PNG header
            // 89  50  4e  47  0d  0a  1a  0a
            let string = "\u{0080}\u{0050}\u{004E}\u{0047}\u{000D}\u{000A}\u{001A}\u{000A}"
            let data = string.data(using: .nonLossyASCII)!
            return .init(data: data, statusCode: 200, headers: nil)
        })
    }
    
    func imageURL(for image: String) -> URL {
        return URL(string: "https://some.url.nl/\(image)")!
    }
    
}
