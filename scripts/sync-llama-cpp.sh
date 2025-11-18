#!/bin/bash
# Script to sync llama.cpp into the repository
# This replaces the submodule with direct inclusion for SPM compatibility

set -e

echo "Syncing llama.cpp..."

# Remove old submodule if it exists
if [ -d "Sources/LlamaSwiftC/llama.cpp" ]; then
    echo "Removing old llama.cpp directory..."
    rm -rf Sources/LlamaSwiftC/llama.cpp
fi

# Clone llama.cpp (shallow clone for speed)
echo "Cloning llama.cpp..."
git clone --depth 1 https://github.com/ggml-org/llama.cpp.git Sources/LlamaSwiftC/llama.cpp

# Remove .git directory so it's not a nested repo
rm -rf Sources/LlamaSwiftC/llama.cpp/.git

echo "Done! llama.cpp is now included directly in the repository."
echo "Commit and push these changes to make it available via SPM."

