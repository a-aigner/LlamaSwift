//
//  LlamaError.swift
//  LlamaSwift
//
//  Custom error types for llama.cpp operations
//

import Foundation

public enum LlamaError: LocalizedError {
    case modelNotFound(String)
    case modelLoadFailed(String)
    case contextCreationFailed(String)
    case inferenceFailed(String)
    case invalidState(String)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let path):
            return "Model file not found at: \(path)"
        case .modelLoadFailed(let message):
            return "Failed to load model: \(message)"
        case .contextCreationFailed(let message):
            return "Failed to create context: \(message)"
        case .inferenceFailed(let message):
            return "Inference failed: \(message)"
        case .invalidState(let message):
            return "Invalid state: \(message)"
        }
    }
}

