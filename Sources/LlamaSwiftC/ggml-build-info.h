//
//  ggml-build-info.h
//  LlamaSwiftC
//
//  Build info definitions for ggml (normally set by CMake)
//  This header should be included before ggml.h
//

#ifndef GGML_BUILD_INFO_H
#define GGML_BUILD_INFO_H

// Define version info if not already defined
#ifndef GGML_VERSION
#define GGML_VERSION "1.0.0"
#endif

#ifndef GGML_COMMIT
#define GGML_COMMIT "unknown"
#endif

#endif /* GGML_BUILD_INFO_H */

