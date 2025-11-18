// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LlamaSwift",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LlamaSwift",
            targets: ["LlamaSwift"]
        ),
    ],
    dependencies: [
        // llama.cpp as a dependency
        // We'll add this once we decide how to include llama.cpp
        // Options:
        // 1. Git submodule
        // 2. SPM package (if available)
        // 3. XCFramework
    ],
    targets: [
        .target(
            name: "LlamaSwift",
            dependencies: ["LlamaSwiftC"]
        ),
        .target(
            name: "LlamaSwiftC",
            dependencies: [],
            exclude: [
                // Exclude Metal shader source file (.metal) - it's embedded as a string in the C++ code
                "llama.cpp/ggml/src/ggml-metal/ggml-metal.metal",
                "llama.cpp/ggml/src/ggml-metal/CMakeLists.txt",
            ],
            // Objective-C++ bridge and llama.cpp source files
            sources: [
                "llama_bridge.mm",
                // llama.cpp core source files (via symlink)
                "llama.cpp/src/llama.cpp",
                "llama.cpp/src/llama-adapter.cpp",
                "llama.cpp/src/llama-arch.cpp",
                "llama.cpp/src/llama-batch.cpp",
                "llama.cpp/src/llama-chat.cpp",
                "llama.cpp/src/llama-context.cpp",
                "llama.cpp/src/llama-cparams.cpp",
                "llama.cpp/src/llama-grammar.cpp",
                "llama.cpp/src/llama-graph.cpp",
                "llama.cpp/src/llama-hparams.cpp",
                "llama.cpp/src/llama-impl.cpp",
                "llama.cpp/src/llama-io.cpp",
                "llama.cpp/src/llama-kv-cache-iswa.cpp",
                "llama.cpp/src/llama-kv-cache.cpp",
                "llama.cpp/src/llama-memory-hybrid.cpp",
                "llama.cpp/src/llama-memory-recurrent.cpp",
                "llama.cpp/src/llama-memory.cpp",
                "llama.cpp/src/llama-mmap.cpp",
                "llama.cpp/src/llama-model-loader.cpp",
                "llama.cpp/src/llama-model-saver.cpp",
                "llama.cpp/src/llama-model.cpp",
                "llama.cpp/src/llama-quant.cpp",
                "llama.cpp/src/llama-sampling.cpp",
                "llama.cpp/src/llama-vocab.cpp",
                "llama.cpp/src/unicode.cpp",
                "llama.cpp/src/unicode-data.cpp",
                // Model architecture implementations - include all .cpp files in models directory
                // Note: SPM doesn't support glob patterns, so we list the directory which includes all files
                "llama.cpp/src/models/afmoe.cpp",
                "llama.cpp/src/models/apertus.cpp",
                "llama.cpp/src/models/arcee.cpp",
                "llama.cpp/src/models/arctic.cpp",
                "llama.cpp/src/models/arwkv7.cpp",
                "llama.cpp/src/models/baichuan.cpp",
                "llama.cpp/src/models/bailingmoe.cpp",
                "llama.cpp/src/models/bailingmoe2.cpp",
                "llama.cpp/src/models/bert.cpp",
                "llama.cpp/src/models/bitnet.cpp",
                "llama.cpp/src/models/bloom.cpp",
                "llama.cpp/src/models/chameleon.cpp",
                "llama.cpp/src/models/chatglm.cpp",
                "llama.cpp/src/models/codeshell.cpp",
                "llama.cpp/src/models/cogvlm.cpp",
                "llama.cpp/src/models/cohere2-iswa.cpp",
                "llama.cpp/src/models/command-r.cpp",
                "llama.cpp/src/models/dbrx.cpp",
                "llama.cpp/src/models/deci.cpp",
                "llama.cpp/src/models/deepseek.cpp",
                "llama.cpp/src/models/deepseek2.cpp",
                "llama.cpp/src/models/dots1.cpp",
                "llama.cpp/src/models/dream.cpp",
                "llama.cpp/src/models/ernie4-5-moe.cpp",
                "llama.cpp/src/models/ernie4-5.cpp",
                "llama.cpp/src/models/exaone.cpp",
                "llama.cpp/src/models/exaone4.cpp",
                "llama.cpp/src/models/falcon-h1.cpp",
                "llama.cpp/src/models/falcon.cpp",
                "llama.cpp/src/models/gemma-embedding.cpp",
                "llama.cpp/src/models/gemma.cpp",
                "llama.cpp/src/models/gemma2-iswa.cpp",
                "llama.cpp/src/models/gemma3-iswa.cpp",
                "llama.cpp/src/models/gemma3n-iswa.cpp",
                "llama.cpp/src/models/glm4-moe.cpp",
                "llama.cpp/src/models/glm4.cpp",
                "llama.cpp/src/models/gpt2.cpp",
                "llama.cpp/src/models/gptneox.cpp",
                "llama.cpp/src/models/granite-hybrid.cpp",
                "llama.cpp/src/models/granite.cpp",
                "llama.cpp/src/models/graph-context-mamba.cpp",
                "llama.cpp/src/models/grok.cpp",
                "llama.cpp/src/models/grovemoe.cpp",
                "llama.cpp/src/models/hunyuan-dense.cpp",
                "llama.cpp/src/models/hunyuan-moe.cpp",
                "llama.cpp/src/models/internlm2.cpp",
                "llama.cpp/src/models/jais.cpp",
                "llama.cpp/src/models/jamba.cpp",
                "llama.cpp/src/models/lfm2.cpp",
                "llama.cpp/src/models/llada-moe.cpp",
                "llama.cpp/src/models/llada.cpp",
                "llama.cpp/src/models/llama-iswa.cpp",
                "llama.cpp/src/models/llama.cpp",
                "llama.cpp/src/models/mamba.cpp",
                "llama.cpp/src/models/minicpm3.cpp",
                "llama.cpp/src/models/minimax-m2.cpp",
                "llama.cpp/src/models/mpt.cpp",
                "llama.cpp/src/models/nemotron-h.cpp",
                "llama.cpp/src/models/nemotron.cpp",
                "llama.cpp/src/models/neo-bert.cpp",
                "llama.cpp/src/models/olmo.cpp",
                "llama.cpp/src/models/olmo2.cpp",
                "llama.cpp/src/models/olmoe.cpp",
                "llama.cpp/src/models/openai-moe-iswa.cpp",
                "llama.cpp/src/models/openelm.cpp",
                "llama.cpp/src/models/orion.cpp",
                "llama.cpp/src/models/pangu-embedded.cpp",
                "llama.cpp/src/models/phi2.cpp",
                "llama.cpp/src/models/phi3.cpp",
                "llama.cpp/src/models/plamo.cpp",
                "llama.cpp/src/models/plamo2.cpp",
                "llama.cpp/src/models/plm.cpp",
                "llama.cpp/src/models/qwen.cpp",
                "llama.cpp/src/models/qwen2.cpp",
                "llama.cpp/src/models/qwen2moe.cpp",
                "llama.cpp/src/models/qwen2vl.cpp",
                "llama.cpp/src/models/qwen3.cpp",
                "llama.cpp/src/models/qwen3moe.cpp",
                "llama.cpp/src/models/qwen3vl-moe.cpp",
                "llama.cpp/src/models/qwen3vl.cpp",
                "llama.cpp/src/models/refact.cpp",
                "llama.cpp/src/models/rwkv6-base.cpp",
                "llama.cpp/src/models/rwkv6.cpp",
                "llama.cpp/src/models/rwkv6qwen2.cpp",
                "llama.cpp/src/models/rwkv7-base.cpp",
                "llama.cpp/src/models/rwkv7.cpp",
                "llama.cpp/src/models/seed-oss.cpp",
                "llama.cpp/src/models/smallthinker.cpp",
                "llama.cpp/src/models/smollm3.cpp",
                "llama.cpp/src/models/stablelm.cpp",
                "llama.cpp/src/models/starcoder.cpp",
                "llama.cpp/src/models/starcoder2.cpp",
                "llama.cpp/src/models/t5-dec.cpp",
                "llama.cpp/src/models/t5-enc.cpp",
                "llama.cpp/src/models/wavtokenizer-dec.cpp",
                "llama.cpp/src/models/xverse.cpp",
                "llama.cpp/src/models/yi.cpp",
                // ggml core source files
                "llama.cpp/ggml/src/ggml.c",
                "llama.cpp/ggml/src/ggml.cpp",
                "llama.cpp/ggml/src/ggml-opt.cpp",
                "llama.cpp/ggml/src/ggml-quants.c",
                "llama.cpp/ggml/src/ggml-backend.cpp",
                "llama.cpp/ggml/src/ggml-backend-reg.cpp",
                "llama.cpp/ggml/src/ggml-alloc.c",
                "llama.cpp/ggml/src/ggml-threading.cpp",
                "llama.cpp/ggml/src/gguf.cpp",
                // ggml CPU backend
                "llama.cpp/ggml/src/ggml-cpu/ggml-cpu.cpp",
                "llama.cpp/ggml/src/ggml-cpu/ggml-cpu.c",
                "llama.cpp/ggml/src/ggml-cpu/ops.cpp",
                "llama.cpp/ggml/src/ggml-cpu/unary-ops.cpp",
                "llama.cpp/ggml/src/ggml-cpu/binary-ops.cpp",
                "llama.cpp/ggml/src/ggml-cpu/vec.cpp",
                "llama.cpp/ggml/src/ggml-cpu/repack.cpp",
                "llama.cpp/ggml/src/ggml-cpu/traits.cpp",
                "llama.cpp/ggml/src/ggml-cpu/hbm.cpp",
                "llama.cpp/ggml/src/ggml-cpu/llamafile/sgemm.cpp",
                // ARM architecture-specific optimizations (for Apple Silicon)
                "llama.cpp/ggml/src/ggml-cpu/arch/arm/cpu-feats.cpp",
                "llama.cpp/ggml/src/ggml-cpu/arch/arm/repack.cpp",
                "llama.cpp/ggml/src/ggml-cpu/arch/arm/quants.c",
                // Generic CPU quantization functions (fallback)
                "llama.cpp/ggml/src/ggml-cpu/quants.c",
                // Metal backend for GPU acceleration on Apple Silicon
                "llama.cpp/ggml/src/ggml-metal/ggml-metal.cpp",
                "llama.cpp/ggml/src/ggml-metal/ggml-metal-common.cpp",
                "llama.cpp/ggml/src/ggml-metal/ggml-metal-ops.cpp",
                "llama.cpp/ggml/src/ggml-metal/ggml-metal-device.cpp",
                "llama.cpp/ggml/src/ggml-metal/ggml-metal-device.mm",
                "llama.cpp/ggml/src/ggml-metal/ggml-metal-context.mm",
                // Exclude ggml-blas.cpp - we use Accelerate framework directly via GGML_USE_ACCELERATE
                // "llama.cpp/ggml/src/ggml-blas/ggml-blas.cpp",
            ],
            publicHeadersPath: ".",
            cxxSettings: [
                // Header search paths - relative to Sources/LlamaSwiftC/
                .headerSearchPath("."),  // For ggml-build-info.h
                .headerSearchPath("llama.cpp/include"),
                .headerSearchPath("llama.cpp"),
                .headerSearchPath("llama.cpp/ggml/include"),
                .headerSearchPath("llama.cpp/ggml/src"),
                .headerSearchPath("llama.cpp/ggml/src/ggml-cpu"),
                .headerSearchPath("llama.cpp/ggml/src/ggml-cpu/arch/arm"),
                .headerSearchPath("llama.cpp/ggml/src/ggml-metal"),  // Metal headers for GPU support
                // C++ standard and optimization flags
                .unsafeFlags([
                    "-std=c++17",
                    "-O3",
                    "-fno-objc-arc",  // Disable ARC for Objective-C files (Metal code uses manual memory management)
                    "-Wno-error",  // Don't treat warnings as errors (for Metal code compatibility)
                    "-Wno-incompatible-pointer-types",  // Allow void* to typed pointer conversions
                    "-DGGML_USE_ACCELERATE",
                    "-DGGML_USE_CPU",  // Enable CPU backend (required for statically linked CPU backend)
                    "-DGGML_USE_METAL",  // Enable Metal for Apple Silicon GPU acceleration
                    "-DNDEBUG",  // Disable assertions in release mode (the NaN/Inf assertion is too strict for some models)
                    // Define version info directly (normally set by CMake)
                    // Use -D with proper string literal syntax for C preprocessor
                    "-DGGML_VERSION=\\\"1.0.0\\\"",
                    "-DGGML_COMMIT=\\\"unknown\\\"",
                    // Explicitly add include path via -I flag as well
                    "-Illama.cpp/include",
                    "-Illama.cpp",
                    "-Illama.cpp/ggml/include",
                    "-Illama.cpp/ggml/src",
                    "-Illama.cpp/ggml/src/ggml-cpu",
                    "-Illama.cpp/ggml/src/ggml-cpu/arch/arm",
                    "-Illama.cpp/ggml/src/ggml-metal",  // Metal include paths for GPU support
                ])
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedFramework("Accelerate"),  // For Apple Silicon optimization
                .linkedFramework("Metal"),       // For Metal GPU acceleration
                .linkedFramework("Foundation"),   // For Foundation types
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)

