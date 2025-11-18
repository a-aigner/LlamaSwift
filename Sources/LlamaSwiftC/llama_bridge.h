//
//  llama_bridge.h
//  LlamaSwiftC
//
//  C interface to llama.cpp (bridged through Objective-C++)
//

#ifndef llama_bridge_h
#define llama_bridge_h

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Backend initialization - must be called before loading models
void llama_bridge_backend_init(void);
void llama_bridge_backend_free(void);

// Model operations - prefixed with llama_bridge_ to avoid conflicts with llama.h
void* llama_bridge_load_model(const char* model_path);
void llama_bridge_free_model(void* model);

// Context operations
void* llama_bridge_create_context(void* model, int32_t n_ctx, int32_t n_threads);
void llama_bridge_free_context(void* context);

// Tokenization
int32_t llama_bridge_tokenize(void* model, const char* text, int32_t* tokens, int32_t n_max_tokens, bool add_bos);

// Generation
int32_t llama_bridge_eval(void* context, const int32_t* tokens, int32_t n_tokens, int32_t n_past);
int32_t llama_bridge_sample_token(void* context);
const char* llama_bridge_token_to_str(void* model, int32_t token);
int32_t llama_bridge_token_eos(void* model);
void llama_bridge_clear_kv_cache(void* context);

#ifdef __cplusplus
}
#endif

#endif /* llama_bridge_h */

