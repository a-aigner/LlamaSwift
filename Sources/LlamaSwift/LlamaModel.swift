//
//  LlamaModel.swift
//  LlamaSwift
//
//  Thread-safe Swift API for llama.cpp
//

import Foundation
import os.log
import LlamaSwiftC

/// Thread-safe wrapper for llama.cpp model operations
/// All operations are serialized through a single DispatchQueue to ensure
/// llama.cpp (which is not thread-safe) is only accessed from one thread
@available(macOS 13.0, iOS 16.0, *)
public actor LlamaModel {
    // Serial queue for all llama.cpp operations
    // CRITICAL: llama.cpp is not thread-safe, so ALL operations must happen on this queue
    private nonisolated let llamaQueue = DispatchQueue(
        label: "com.mycorp.llama.operations",
        qos: .userInitiated
    )
    
    private var model: OpaquePointer?
    private var context: OpaquePointer?
    private var isLoaded = false
    private var isGenerating = false
    private var hasGenerated = false // Track if we've done any generation yet
    
    private let logger = Logger(subsystem: "com.mycorp.llama", category: "LlamaModel")
    
    /// Load a model from the given path
    /// - Parameter modelPath: Path to the GGUF model file
    public static func load(from modelPath: String) async throws -> LlamaModel {
        let instance = LlamaModel()
        try await instance.loadModel(path: modelPath)
        return instance
    }
    
    private init() {
        logger.info("LlamaModel initialized")
        // Initialize llama.cpp backends (CPU, etc.)
        llama_bridge_backend_init()
    }
    
    deinit {
        // Cleanup will happen on llamaQueue
        llamaQueue.sync {
            unloadModel()
            // Free backends after unloading model
            llama_bridge_backend_free()
        }
    }
    
    /// Load the model (internal)
    private func loadModel(path: String) async throws {
        logger.info("Loading model from: \(path)")
        
        guard FileManager.default.fileExists(atPath: path) else {
            throw LlamaError.modelNotFound(path)
        }
        
        // Load model on llamaQueue to ensure thread safety
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            llamaQueue.async {
                let modelPtrRaw = path.withCString { llama_bridge_load_model($0) }
                guard let modelPtrRaw = modelPtrRaw else {
                    self.logger.error("Failed to load model")
                    continuation.resume(throwing: LlamaError.modelLoadFailed("llama_load_model returned nil"))
                    return
                }
                let modelPtr = OpaquePointer(modelPtrRaw)
                
                // Create context with reasonable defaults
                // Use 4096 context size (common default) and auto-detect thread count
                let threadCount = max(1, ProcessInfo.processInfo.processorCount)
                let contextPtrRaw = llama_bridge_create_context(modelPtrRaw, 4096, Int32(threadCount))
                guard let contextPtrRaw = contextPtrRaw else {
                    llama_bridge_free_model(modelPtrRaw)
                    self.logger.error("Failed to create context")
                    continuation.resume(throwing: LlamaError.contextCreationFailed("llama_create_context returned nil"))
                    return
                }
                let contextPtr = OpaquePointer(contextPtrRaw)
                
                self.model = modelPtr
                self.context = contextPtr
                self.isLoaded = true
                self.logger.info("Model loaded successfully")
                continuation.resume()
            }
        }
    }
    
    /// Unload the model
    public func unload() async {
        logger.info("Unloading model")
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            llamaQueue.async {
                self.unloadModel()
                continuation.resume()
            }
        }
    }
    
    private func unloadModel() {
        if let ctx = context {
            llama_bridge_free_context(UnsafeMutableRawPointer(ctx))
            context = nil
        }
        if let mdl = model {
            llama_bridge_free_model(UnsafeMutableRawPointer(mdl))
            model = nil
        }
        isLoaded = false
        logger.info("Model unloaded")
    }
    
    /// Generate tokens for the given prompt (streaming)
    /// - Parameter prompt: The input prompt
    /// - Returns: AsyncThrowingStream of tokens
    public func generate(prompt: String) async throws -> AsyncThrowingStream<String, Error> {
        logger.info("Generating response for prompt (length: \(prompt.count))")
        
        guard isLoaded else {
            throw LlamaError.invalidState("Model is not loaded")
        }
        
        guard !isGenerating else {
            throw LlamaError.invalidState("Generation already in progress")
        }
        
        isGenerating = true
        
        return AsyncThrowingStream { continuation in
            // Run all llama.cpp operations on llamaQueue
            self.llamaQueue.async {
                defer {
                    // Reset isGenerating flag on the actor
                    Task {
                        await self.setGenerating(false)
                    }
                }
                
                do {
                    let tokens = try self.generateTokens(prompt: prompt)
                    
                    for token in tokens {
                        continuation.yield(token)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func setGenerating(_ value: Bool) {
        isGenerating = value
    }
    
    /// Generate tokens (internal, runs on llamaQueue - must be called from llamaQueue)
    private func generateTokens(prompt: String) throws -> [String] {
        guard let modelPtr = model, let contextPtr = context else {
            throw LlamaError.invalidState("Model or context not initialized")
        }
        
        // Tokenize prompt
        var tokens = [Int32](repeating: 0, count: 1024)
        let promptCString = prompt.cString(using: .utf8)
        guard let promptCString = promptCString else {
            throw LlamaError.inferenceFailed("Failed to convert prompt to C string")
        }
        
        let n_tokens = promptCString.withUnsafeBufferPointer { buffer in
            llama_bridge_tokenize(UnsafeMutableRawPointer(modelPtr), buffer.baseAddress!, &tokens, 1024, true)
        }
        guard n_tokens > 0 && n_tokens <= 1024 else {
            throw LlamaError.inferenceFailed("Failed to tokenize prompt or too many tokens")
        }
        
        // Generate tokens
        var result: [String] = []
        
        // Always clear KV cache to ensure clean state for each generation
        // This ensures we start from a known good state
        llama_bridge_clear_kv_cache(UnsafeMutableRawPointer(contextPtr))
        
        // Evaluate initial tokens
        // llama_batch_get_one automatically sets positions starting from 0
        // The positions will be tracked automatically by llama_decode
        var initialTokens = Array(tokens[0..<Int(n_tokens)])
        let evalResult = llama_bridge_eval(UnsafeMutableRawPointer(contextPtr), &initialTokens, Int32(n_tokens), 0)
        guard evalResult == 0 else {
            throw LlamaError.inferenceFailed("Failed to evaluate tokens: \(evalResult)")
        }
        
        var n_past = Int(n_tokens)
        
        // Generate response tokens
        let maxTokens = 512
        for _ in 0..<maxTokens {
            // Sample next token
            let newToken = llama_bridge_sample_token(UnsafeMutableRawPointer(contextPtr))
            guard newToken >= 0 else {
                logger.error("Invalid token sampled: \(newToken)")
                break
            }
            
            if newToken == llama_bridge_token_eos(UnsafeMutableRawPointer(modelPtr)) {
                logger.info("EOS token received, stopping generation")
                break
            }
            
            // Convert token to string
            if let tokenStrPtr = llama_bridge_token_to_str(UnsafeMutableRawPointer(modelPtr), newToken) {
                let tokenString = String(cString: tokenStrPtr)
                if !tokenString.isEmpty {
                    result.append(tokenString)
                }
            }
            
            // Evaluate new token
            var newTokenArray = [newToken]
            let evalResult = llama_bridge_eval(UnsafeMutableRawPointer(contextPtr), &newTokenArray, 1, Int32(n_past))
            if evalResult != 0 {
                if evalResult < 0 {
                    logger.error("Fatal error during evaluation: \(evalResult)")
                }
                break
            }
            n_past += 1
        }
        
        hasGenerated = true
        return result
    }
}

