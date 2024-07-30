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

    override func setUpWithError() throws {
        HTTPStubs.setEnabled(true)
    }

    override func tearDownWithError() throws {
        HTTPStubs.setEnabled(false)
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
