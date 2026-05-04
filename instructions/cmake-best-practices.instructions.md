---
applyTo: "**/CMakeLists.txt,**/*.cmake"
description: "CMake best practices: modern target-based CMake 3.16+, FetchContent, CTest, generator expressions. Use when working on CMake files."
---

## CMake Best Practices

- Minimum version 3.16+. Use `cmake_minimum_required(VERSION 3.16)`.
- Modern CMake: target-based, not directory-based.
- No `include_directories()` → use `target_include_directories()`.
- No `link_libraries()` → use `target_link_libraries()` with `PUBLIC`/`PRIVATE`/`INTERFACE`.
- Use `FetchContent` or `find_package` for dependencies.
- Set `CMAKE_EXPORT_COMPILE_COMMANDS ON` for clang-tidy and IDE tooling.
- Use generator expressions for config-dependent settings: `$<BUILD_INTERFACE:...>`, `$<INSTALL_INTERFACE:...>`.
- Separate build from source: `cmake -B build -S .`.
- Build: `cmake --build build` (or `cmake --build build -j$(nproc)`).
- Install: `cmake --install build --prefix /usr/local`.

## CTest Integration

- Enable testing with `enable_testing()` or `include(CTest)`.
- Add tests with `add_test(NAME <name> COMMAND <target>)`.
- For GoogleTest: use `include(GoogleTest)` + `gtest_discover_tests(<target>)`.
- Run: `ctest --test-dir build` or `ctest --test-dir build -V` for verbose.

## Project Structure Convention

```
project/
├── CMakeLists.txt          # Top-level
├── src/
│   ├── CMakeLists.txt      # Library/executable targets
│   └── module/
├── include/
│   └── project/            # Public headers
├── tests/
│   ├── CMakeLists.txt      # Test targets
│   └── test_module.cpp
├── cmake/                  # Custom Find modules, toolchain files
└── build/                  # Out-of-source build (gitignored)
```
