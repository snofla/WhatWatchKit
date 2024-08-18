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

    /// Check whether an image at a url has watches. This uses a separate
    /// object detection neural network.
    public static func anyWatches(in imageURL: URL) async throws -> Watches {
        guard let image = await Task(operation: {
            return CIImage(contentsOf: imageURL)
        }).value else {
            throw NSError(domain: #fileID, code: #line, userInfo: [NSLocalizedDescriptionKey: "Error getting image from url \(imageURL)"])
        }
        return try await Self.anyWatches(in: image)
    }
    
    /// Check whether an image has watches. This uses a separate
    /// object detection neural network.
    public static func anyWatches(in cImage: CIImage) async throws -> Watches {
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
    public static func anyWatches(in image: CGImage) async throws -> Watches {
        let originalImage = CIImage(cgImage: image)
        let input = try WhetherWatchModelInput(imageWith: image)
        let modelResult = try await self.model.prediction(input: input)
        let confidences: [Double] = (0..<modelResult.confidence.count).map { index in
            return modelResult.confidence[index].doubleValue
        }
        let inputImageSize: CGSize = {
            // get size of image used by the model
            let width = CVPixelBufferGetWidth(input.image)
            let height = CVPixelBufferGetHeight(input.image)
            return .init(width: width, height: height)
        }()
        let numberOfCoords = modelResult.coordinatesShapedArray.count
        let coordinates: [Rect] = (0..<numberOfCoords).compactMap { index in
            // rectangle returned by model
            guard let modelRect = modelResult.coordinates[coordAt: index] else {
                return nil
            }
            let modelSize = modelRect.size
            // The rectangle coords of detected objects are using the top/left coordinate
            // system where the (x, y) components of the rectangle coords are in the center
            // of the rectangle.
            // The following calculation gets us the rectangle of the detected object
            // within the original image used to detect ther 
            let rect = modelRect
                // 1a. de-center
                .offsetBy(dx: -modelSize.width / 2, dy: -modelSize.height / 2)
                // 1.b scale
                .applying(
                    .init(
                        scaleX: inputImageSize.width,
                        y: inputImageSize.height
                    )
                )
                // 2. translate to CIImage coordinate system
                .applying(
                    .init(scaleX: 1, y: -1)
                    .translatedBy(x: 0, y: -inputImageSize.height)
                )
            return rect
        }
        return Watches(
            originalImage: originalImage,
            modelImageSize: .init(
                width: inputImageSize.width,
                height: inputImageSize.height
            ),
            confidences: confidences,
            coordinates: coordinates
        )
    }
    
    /// Extracts a watch from a result
    public static func extractWatch(at index: Int, from watches: Watches) async throws -> CIImage? {
        guard index < watches.coordinates.count else {
            return nil
        }
        let original = CGSize(width: watches.originalImage.extent.width, height: watches.originalImage.extent.height)
        let model = CGSize(width: watches.modelImageSize.width, height: watches.modelImageSize.height)
        // scale up model coords to original image coords
        let rect = watches.coordinates[index]
            .applying(
                .init(
                    scaleX: original.width / model.width, 
                    y: original.height / model.height
                )
            )
        let cropped = watches.originalImage.cropped(to: rect)
        return cropped
    }
    
}


extension Whether {
    
    fileprivate static let model = {
        let whetherModel = try! WhetherWatchModel()
        return whetherModel
    }()

}


extension Whether {
    
    public struct Watches {
        
        public var count: Int {
            return self.coordinates.count
        }
        
        public var isEmpty: Bool {
            return self.coordinates.isEmpty
        }
        
        /// Original image
        public let originalImage: CIImage
        /// Size of image created for model
        public let modelImageSize: CGSize
        /// List of confidences for each detected object
        public let confidences: [Double]
        /// List of coordinates for each detected object
        public let coordinates: [Rect]
    }

    #if os(iOS) || os(watchOS) || os(tvOS)
    public typealias Rect = CGRect
    #else
    public typealias Rect = NSRect
    #endif
    
}


extension Whether.Watches: AsyncSequence {

    public typealias Element = CIImage
    
    public func makeAsyncIterator() -> AsyncIterator {
        return Self.AsyncIterator(result: self, current: 0)
    }
        
    public struct AsyncIterator: AsyncIteratorProtocol {
        
        public mutating func next() async -> Element? {
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

        let result: Whether.Watches
        var current: Int
    }
    
}



extension MLMultiArray {
    
    subscript(coordAt index: Int) -> Whether.Rect? {
        guard self.count > index else {
            return nil
        }
        let x = self[[index, 0] as [NSNumber]].doubleValue
        let y = self[[index, 1] as [NSNumber]].doubleValue
        let w = self[[index, 2] as [NSNumber]].doubleValue
        let h = self[[index, 3] as [NSNumber]].doubleValue
        return .init(x: x, y: y, width: w, height: h)
    }
    
}
