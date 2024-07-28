//
//  Whether.swift
//
//
//  Created by Alfons Hoogervorst on 27/07/2024.
//

import Foundation
import CoreML
import CoreImage

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#else
#endif


public struct Whether {
    
    /// Check whether an image has watches. This uses a separate
    /// object detection neural network.
    public static func anyWatches(in cImage: CIImage) async throws -> Result {
        let image: CGImage? = await Task {
            let context = CIContext()
            return context.createCGImage(cImage, from: cImage.extent)
        }.value
        guard let image = image else {
            throw NSError(domain: #fileID, code: #line, userInfo: [NSLocalizedDescriptionKey: "Error creating CGImage"])
        }
        return try await Self.anyWatches(in: image)
    }

    /// Check whether an image has watches. This uses a separate
    /// object detection neural network.
    public static func anyWatches(in image: CGImage) async throws -> Result {
        let input = try WhetherWatchModelInput(imageWith: image)
        let modelResult = try await self.model.prediction(input: input)
        let confidences: [Double] = (0..<modelResult.confidence.count).map { index in
            return modelResult.confidence[index].doubleValue
        }
        let inputImageSize: CGSize = {
            let extent = CIImage(cvPixelBuffer: input.image).extent
            return .init(width: extent.width, height: extent.height)
        }()
        let coordinates: [Rect] = (0..<modelResult.coordinatesShapedArray.count).map { index in
            // coordinates are centered in neural network's input image
            let coordinates = modelResult.coordinates
            let x = coordinates[0].doubleValue
            let y = coordinates[1].doubleValue
            let w = coordinates[2].doubleValue
            let h = coordinates[3].doubleValue
            // center, and scale width and height
            let rect = CGRect(
                origin: .init(
                    x: x - (w / 2),
                    y: y - (h / 2)
                ),
                size: .init(
                    width: w,
                    height: h
                )
            ).applying(
                .init(
                    scaleX: inputImageSize.width,
                    y: inputImageSize.height
                )
            )
            return rect
        }
        return Result(
            image: image,
            size: .init(
                width: inputImageSize.width,
                height: inputImageSize.height
            ),
            confidence: confidences,
            coordinates: coordinates
        )
    }
    
    /// Extracts a watch from a result
    public static func extractWatch(at index: Int, from result: Result) async throws -> CGImage? {
        guard index < result.coordinates.count else {
            return nil
        }
        let original = CGSize(width: result.image.width, height: result.image.height)
        let model = CGSize(width: result.size.width, height: result.size.height)
        // scale up model coords to original image coords
        let rect = result.coordinates[index]
            .applying(.init(scaleX: original.width / model.width, y: original.height / model.height))
        let cropped = await Task {
            return result.image.cropping(to: rect)
        }.value
        guard let cropped = cropped else {
            return nil
        }
        return cropped
    }
    
}


extension Whether {
    
    fileprivate static let model = {
        let whatModel = try! WhetherWatchModel()
        return whatModel
    }()

}


extension Whether {
    
    public struct Result {
        
        public var count: Int {
            return self.coordinates.count
        }
        
        public var isEmpty: Bool {
            return self.coordinates.isEmpty
        }
        
        /// Original image
        public let image: CGImage
        /// Size of image created for model
        public let size: CGSize
        /// List of confidences for each detected object
        public let confidence: [Double]
        /// List of coordinates for each detected object
        public let coordinates: [Rect]
    }

    #if os(iOS) || os(watchOS) || os(tvOS)
    public typealias Rect = CGRect
    #else
    public typealias Rect = NSRect
    #endif
    
}


extension Whether.Result: AsyncSequence {

    public typealias Element = CGImage
    
    public func makeAsyncIterator() -> AsyncIterator {
        return Self.AsyncIterator(result: self, current: 0)
    }
        
    public struct AsyncIterator: AsyncIteratorProtocol {
        
        public mutating func next() async -> CGImage? {
            guard self.current < self.result.count else {
                return nil
            }
            let current = self.current
            let result = self.result
            let image = await Task {
                do {
                    return try await Whether.extractWatch(at: current, from: result)
                } catch {
                    return nil
                }
            }.value
            self.current += 1
            return image
        }

        let result: Whether.Result
        var current: Int
    }
    
}
