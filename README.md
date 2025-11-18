# LlamaSwift

A thread-safe Swift wrapper for llama.cpp, designed with proper concurrency handling from the ground up. LlamaSwift provides a modern, async/await-based API for running large language models on macOS and iOS with full support for Apple Silicon GPU acceleration via Metal.

## Features

- ✅ **Thread-safe**: All llama.cpp operations run on a single serial queue
- ✅ **Actor-based**: Uses Swift actors for isolation
- ✅ **Async/await**: Modern Swift concurrency support
- ✅ **Streaming**: Token-by-token generation with async sequences
- ✅ **Memory safe**: Proper resource management
- ✅ **GPU Acceleration**: Metal backend support for Apple Silicon
- ✅ **Multi-platform**: Supports macOS 13+ and iOS 16+

## Requirements

- macOS 13.0+ or iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- llama.cpp (included as source)

## Installation

### Swift Package Manager

Add LlamaSwift to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/yourusername/LlamaSwift.git`
3. Select the version or branch you want to use
4. Add `LlamaSwift` to your target's dependencies

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/LlamaSwift.git", from: "1.0.0")
]
```

## Usage

### Basic Example

```swift
import LlamaSwift

// Load a model
let model = try await LlamaModel.load(from: "/path/to/model.gguf")

// Generate text with streaming
let stream = try await model.generate(prompt: "Hello, how are you?")

for try await token in stream {
    print(token, terminator: "")
}
```

### Advanced Example

```swift
import LlamaSwift

// Load model with custom parameters
let model = try await LlamaModel.load(
    from: "/path/to/model.gguf",
    contextSize: 4096,
    useGPU: true  // Enable Metal GPU acceleration
)

// Generate with custom parameters
let stream = try await model.generate(
    prompt: "Write a story about",
    maxTokens: 100,
    temperature: 0.7,
    topP: 0.9
)

// Process tokens as they arrive
for try await token in stream {
    // Handle each token
    processToken(token)
}
```

## Architecture

### Thread Safety

The wrapper ensures thread safety by:
1. Using a single serial `DispatchQueue` for all llama.cpp operations
2. Wrapping the API in an `Actor` for Swift-level isolation
3. Never allowing concurrent access to llama.cpp structures

### Integration with llama.cpp

The wrapper bridges to llama.cpp through:
1. **C Interface** (`llama_bridge.h`): C functions that wrap llama.cpp
2. **Objective-C++ Bridge** (`llama_bridge.mm`): Implements the C interface using llama.cpp
3. **Swift API** (`LlamaModel.swift`): Swift-friendly async/await API

### Backends

- **CPU**: Optimized CPU backend using Accelerate framework
- **Metal**: GPU acceleration on Apple Silicon devices

## API Reference

### LlamaModel

The main entry point for loading and using models.

#### Methods

- `load(from:contextSize:useGPU:)` - Load a model from a file path
- `generate(prompt:maxTokens:temperature:topP:)` - Generate text with streaming support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

[Add your license here - e.g., MIT, Apache 2.0, etc.]

## Acknowledgments

- Built on top of [llama.cpp](https://github.com/ggerganov/llama.cpp) by Georgi Gerganov

