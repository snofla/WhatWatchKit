//
//  What.swift
//
//
//  Created by Alfons Hoogervorst on 27/07/2024.
//
import Foundation
import CoreImage
import CoreML

public struct What {
    
    /// Guesses the watch from the image retrieved from a URL.
    /// - Parameter url: URL to retrieve image from
    /// - Returns: Array of results, sorted by their confidence
    /// level.
    public static func categoryOfWatch(at url: URL) async throws -> [Result] {
        let input = try WhatWatchModelInput(imageAt: url)
        let modelResult: WhatWatchModelOutput = try await self.model.prediction(input: input)
        let ourResult = [Result](modelResult)
            .sorted(by: { lhs, rhs in
                return lhs.confidence > rhs.confidence
            })
        return ourResult
    }
    
    public static func categoryOfWatch(in image: CIImage) async throws -> [Result] {
        guard let image = CIContext().createCGImage(image, from: image.extent) else {
            throw NSError(domain: #fileID, code: #line, userInfo: [NSLocalizedDescriptionKey: "Error creating CGImage"])
        }
        let input = try WhatWatchModelInput(imageWith: image)
        let modelResult: WhatWatchModelOutput = try await self.model.prediction(input: input)
        let ourResult = [Result](modelResult)
            .sorted(by: { lhs, rhs in
                return lhs.confidence > rhs.confidence
            })
        return ourResult
    }


}


extension What {
    
    /// Model initialiser for recognizing watches.
    fileprivate static let model = {
        let whatModel = try! WhatWatchModel()
        return whatModel
    }()
    
}


extension What {
    
    public enum Category: String {
        case unknown
        case chronograph
        case diver
        case dress
        case field
        case gmt
        case pilot
        case sport
        
        public init(_ string: String) {
            self = .init(rawValue: string.lowercased()) ?? .unknown
        }

        init(_ feature: MLFeatureValue) {
            let value = feature.stringValue.lowercased()
            self = .init(rawValue: value) ?? .unknown
        }
        
    }
    
    public struct Result {
        let label: What.Category
        let confidence: Double
    }
    
}


extension Array where Element == What.Result {
    
    init(_ modelOutput: WhatWatchModelOutput) {
        let elements: [What.Result] = modelOutput.targetProbability.map { kv in
            return .init(label: .init(kv.key), confidence: kv.value)
        }
        self = elements
    }
    
}
