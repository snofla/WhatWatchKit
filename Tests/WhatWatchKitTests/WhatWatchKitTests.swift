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
        let image3 = self.pixelBuffer(from: image)!
        let results2 = try await What.categoryOfWatch(in: image3)
        XCTAssert(results2.count > 1)
        XCTAssert(results2.first!.label == .diver)
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
        let image3 = self.pixelBuffer(from: image)!
        let results2 = try await What.categoryOfWatch(in: image3)
        XCTAssert(results2.count > 1)
        XCTAssert(results2.first!.label == .dress)
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
        let image3 = self.pixelBuffer(from: image)!
        let results2 = try await What.categoryOfWatch(in: image3)
        XCTAssert(results2.count > 1)
        XCTAssert(results2.first!.label == .sport)
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
        let image3 = self.pixelBuffer(from: image)!
        let results2 = try await What.categoryOfWatch(in: image3)
        XCTAssert(results2.count > 1)
        XCTAssert(results2.first!.label == .chronograph)
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
        let image3 = self.pixelBuffer(from: image)!
        let results2 = try await What.categoryOfWatch(in: image3)
        XCTAssert(results2.count > 1)
        XCTAssert(results2.first!.label == .field)
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
        let image3 = self.pixelBuffer(from: image)!
        let results2 = try await What.categoryOfWatch(in: image3)
        XCTAssert(results2.count > 1)
        XCTAssert(results2.first!.label == .gmt)
    }

    func imageURL(for name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "png")
    }
    
    func pixelBuffer(from image: CIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuf: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(image.extent.width.rounded()), Int(image.extent.height.rounded()),
            kCVPixelFormatType_32ARGB, attrs, &pixelBuf
        )
        guard status == kCVReturnSuccess, let pixelBuf else {
            return nil
        }
        let context = CIContext()
        context.render(image, to: pixelBuf)
        return pixelBuf
    }
    
}



extension WhatWatchKitTests {
    
    /// Tests whether our image has multiple watches, and whether
    /// they are all sports watches (they're my Citizen Tsuyosas)
    func test_Whether_All_Sports() async throws {
        let image = CIImage(contentsOf: self.imageURL(for: "all_sport")!)!
        let result = try await Whether.anyWatches(in: image)
        XCTAssertTrue(!result.isEmpty, "Should have results")
        for try await watchImage in result {
            let category = try await What.categoryOfWatch(in: watchImage)
            let labels: Set<What.Label> = category.reduce(into: Set(), { partialResult, result in
                partialResult.insert(result.label)
            })
            XCTAssertTrue(category.first?.label == .sport, "Should be a sport watch")
            #if WHAT_WATCH_MODEL_SHOULD_BE_RETRAINED
            if let label = category.first?.label, label != .sport {
                print("Warning: one image is not confidently a sport")
            }
            #endif // WHAT_WATCH_MODEL_SHOULD_BE_RETRAINED
            XCTAssert(labels.contains(.sport), "Should be sport-like")
        }
    }
        
    func test_Whether_Not_A_Watch() async throws {
        let image = CIImage(contentsOf: self.imageURL(for: "not_a_watch")!)!
        let result = try await Whether.anyWatches(in: image)
        XCTAssertTrue(result.isEmpty, "Should not have results")
    }

    /// Checks a distance photo with a GMT watch
    /// Image from https://unsplash.com/photos/person-wearing-silver-link-bracelet-round-analog-watch-WSOaS0Eef_w
    func test_Whether_Gmt_Far() async throws {
        let image = CIImage(contentsOf: self.imageURL(for: "gmt_far")!)!
        let result = try await Whether.anyWatches(in: image)
        XCTAssertTrue(result.count == 1, "Should have one image")
        let watchImage_ = try await Whether.extractWatch(at: 0, from: result)
        XCTAssertNotNil(watchImage_)
        let watchImage = watchImage_!
        let category = try await What.categoryOfWatch(in: watchImage)
        XCTAssertTrue(category.count > 0, "Should have categories")
        XCTAssertTrue(category[0].label == .gmt, "Should have GMT")
        #if TEST_GMT_FAR_IMAGE
        let ciImage = CIImage(cgImage: watchImage)
        print("\(ciImage)")
        #endif // TEST_GMT_FAR_IMAGE
    }

}
