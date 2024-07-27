// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CoreML

public struct Recognize {
    
    /// Guesses the watch from the image retrieved from a URL.
    /// - Parameter url: URL to retrieve image from
    /// - Returns: Array of results, sorted by their confidence
    /// level.
    public static func categoryOfWatch(at url: URL) async throws -> [Result] {
        let input = try WhatWatchModelInput(imageAt: url)
        let modelResult: WhatWatchModelOutput = try await self.watchModel.prediction(input: input)
        let ourResult = [Result](modelResult)
            .sorted(by: { lhs, rhs in
                return lhs.confidence > rhs.confidence
            })
        return ourResult
    }

}


extension Recognize {
    
    /// Model initialiser for recognizing watches.
    static let watchModel = {
        let watchModel = try! WhatWatchModel()
        return watchModel
    }()
    
}


extension Recognize {
    
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
        let label: Recognize.Category
        let confidence: Double
    }
    
}


extension Array where Element == Recognize.Result {
    
    init(_ modelOutput: WhatWatchModelOutput) {
        let elements: [Recognize.Result] = modelOutput.targetProbability.map { kv in
            return .init(label: .init(kv.key), confidence: kv.value)
        }
        self = elements
    }
    
}
