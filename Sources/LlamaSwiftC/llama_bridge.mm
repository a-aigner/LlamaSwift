//
//  llama_bridge.mm
//  LlamaSwiftC
//
//  Objective-C++ bridge to llama.cpp
//  This file provides a C interface to llama.cpp functions
//

#import "llama_bridge.h"
#include <string>
#include <cstring>

// Include build info before llama.cpp headers
#include "ggml-build-info.h"

// Include llama.cpp headers
// Header search paths are configured in Package.swift
#include "llama.h"
#include "ggml-backend.h"
#include "ggml-cpu.h"

// For now, these are placeholder implementations
// Once llama.cpp is integrated, we'll implement the actual bridge

void llama_bridge_backend_init(void) {
    llama_backend_init();
    
    // Explicitly initialize and register the CPU backend
    // This ensures the static backend registry is initialized with the CPU backend
    #ifdef GGML_USE_CPU
    ggml_backend_register(ggml_backend_cpu_reg());
    #endif
    
    // Load all available dynamic backends (Metal if enabled, etc.)
    ggml_backend_load_all();
    
    // Verify at least one backend is registered
    if (ggml_backend_reg_count() == 0) {
        // If no backends, try to register CPU backend again
        #ifdef GGML_USE_CPU
        ggml_backend_register(ggml_backend_cpu_reg());
        #endif
    }
}

void llama_bridge_backend_free(void) {
    llama_backend_free();
}

void* llama_bridge_load_model(const char* model_path) {
    llama_model_params params = llama_model_default_params();
    struct llama_model* model = llama_load_model_from_file(model_path, params);
    return model;
}

void llama_bridge_free_model(void* model) {
    if (model) {
        llama_model_free((struct llama_model*)model);
    }
}

void* llama_bridge_create_context(void* model, int32_t n_ctx, int32_t n_threads) {
    if (!model) return nullptr;
    
    llama_context_params params = llama_context_default_params();
    // Use default n_ctx from model if n_ctx is 0 or negative, otherwise use provided value
    if (n_ctx > 0) {
        params.n_ctx = n_ctx;
    }
    // Set thread count
    if (n_threads > 0) {
        params.n_threads = n_threads;
        params.n_threads_batch = n_threads;
    }
    // Ensure we have a valid context size
    if (params.n_ctx <= 0) {
        params.n_ctx = 512; // Minimum safe context size
    }
    // Use llama_init_from_model which is the recommended API
    // This properly initializes the context with memory
    return llama_init_from_model((struct llama_model*)model, params);
}

void llama_bridge_free_context(void* context) {
    if (context) {
        llama_free((struct llama_context*)context);
    }
}

int32_t llama_bridge_tokenize(void* model, const char* text, int32_t* tokens, int32_t n_max_tokens, bool add_bos) {
    if (!model || !text || !tokens) return 0;
    
    struct llama_model* mdl = (struct llama_model*)model;
    const struct llama_vocab* vocab = llama_model_get_vocab(mdl);
    if (!vocab) return 0;
    
    int32_t text_len = (int32_t)strlen(text);
    // llama_tokenize signature: (vocab, text, text_len, tokens, n_tokens_max, add_special, parse_special)
    // add_bos maps to add_special (true = add BOS token)
    // parse_special = false (don't parse special tokens as plaintext)
    return llama_tokenize(vocab, text, text_len, tokens, n_max_tokens, add_bos, false);
}

int32_t llama_bridge_eval(void* context, const int32_t* tokens, int32_t n_tokens, int32_t n_past) {
    if (!context || !tokens || n_tokens <= 0) return -1;
    
    // Use llama_batch_get_one for simpler single-sequence evaluation
    // This automatically sets up positions, sequence IDs, and logits
    // According to llama.h: if logits is NULL, only the last token outputs logits (which is what we want)
    struct llama_batch batch = llama_batch_get_one((llama_token*)tokens, n_tokens);
    
    // llama_decode takes batch by value, not pointer
    int result = llama_decode((struct llama_context*)context, batch);
    return result;
}

int32_t llama_bridge_sample_token(void* context) {
    if (!context) return -1;
    
    struct llama_context* ctx = (struct llama_context*)context;
    const struct llama_model* model = llama_get_model(ctx);
    const struct llama_vocab* vocab = llama_model_get_vocab(model);
    if (!vocab) return -1;
    
    // Get logits for the last token
    float* logits = llama_get_logits(ctx);
    int n_vocab = llama_vocab_n_tokens(vocab);
    
    // Simple greedy sampling - find token with highest probability
    int best_token = 0;
    float best_logit = logits[0];
    for (int i = 1; i < n_vocab; i++) {
        if (logits[i] > best_logit) {
            best_logit = logits[i];
            best_token = i;
        }
    }
    
    return best_token;
}

const char* llama_bridge_token_to_str(void* model, int32_t token) {
    if (!model) return nullptr;
    
    struct llama_model* mdl = (struct llama_model*)model;
    const struct llama_vocab* vocab = llama_model_get_vocab(mdl);
    if (!vocab) return nullptr;
    
    // Use a static buffer that's large enough for most tokens
    // This avoids thread_local issues and is safe since we're on llamaQueue
    static char buffer[256];
    // llama_token_to_piece signature: (vocab, token, buf, length, lstrip, special)
    int n = llama_token_to_piece(vocab, token, buffer, sizeof(buffer) - 1, 0, false);
    if (n < 0) {
        // Token is too large, return empty string
        return nullptr;
    }
    if (n == 0) {
        return nullptr;
    }
    
    buffer[n] = '\0'; // Ensure null termination
    return buffer;
}

int32_t llama_bridge_token_eos(void* model) {
    if (!model) return -1;
    
    struct llama_model* mdl = (struct llama_model*)model;
    const struct llama_vocab* vocab = llama_model_get_vocab(mdl);
    if (!vocab) return -1;
    
    return llama_vocab_eos(vocab);
}

void llama_bridge_clear_kv_cache(void* context) {
    if (context) {
        // Clear memory for sequence 0 (the default sequence)
        // The second parameter (data=true) clears data buffers, not just metadata
        struct llama_context* ctx = (struct llama_context*)context;
        llama_memory_t mem = llama_get_memory(ctx);
        if (mem) {
            llama_memory_clear(mem, true); // Clear sequence 0, including data buffers
        }
    }
}

