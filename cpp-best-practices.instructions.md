---
applyTo: "**/*.{c,cpp,h,hpp,cc,cxx,hxx,inl}"
description: "C/C++ best practices: modern C++17/20/23, RAII, smart pointers, const-correctness, clang-format, clang-tidy, GoogleTest, CTest. Use when working on C or C++ files."
---

## C++ Best Practices

- Write modern C++ (C++17/20/23). Prefer RAII, smart pointers (`std::unique_ptr`, `std::shared_ptr`), move semantics.
- No raw `new`/`delete` unless interfacing with C API. Use `std::make_unique`.
- Prefer `std::string_view` over `const std::string&` for read-only params.
- Use `constexpr` and `consteval` where possible.
- Header guards: `#pragma once` or include guards.
- Error handling: exceptions for C++, return codes for C. No silent failures.
- Follow RAII pattern — resource acquisition is initialization, always.
- Use `std::optional`, `std::variant`, `std::expected` over error codes in modern C++.
- const-correctness everywhere. If it doesn't change, mark `const`.
- Prefer algorithms (`std::ranges`, `<algorithm>`) over raw loops.
- Code comments: write in normal clear language, not caveman style.

## C Best Practices

- C11 or C17 standard. No VLAs.
- Always check return values of `malloc`, `fopen`, etc.
- Free what you allocate. Match every `malloc` with `free`.
- Use `static` for file-scope functions (internal linkage).
- Opaque pointer pattern for encapsulation.

## Formatting & Static Analysis

- Use `.clang-format` for consistent style. If project has one, respect it. If not, suggest creating one (e.g. `BasedOnStyle: LLVM` or `Google`).
- Use `.clang-tidy` for static analysis. Enable at minimum: `bugprone-*`, `cppcoreguidelines-*`, `modernize-*`, `performance-*`, `readability-*`.
- Run `clang-format -i <file>` to format. Run `clang-tidy <file>` to lint.
- Never mix formatting changes with logic changes in the same commit.

## Testing — GoogleTest / CTest

- Use GoogleTest (`gtest`) for unit tests. One test file per source module: `foo.cpp` → `foo_test.cpp`.
- Use `TEST()` for free functions, `TEST_F()` with fixtures for stateful tests.
- Naming: `TEST(ModuleName, DescriptiveTestCase)` — e.g. `TEST(Parser, RejectsEmptyInput)`.
- Assertions: `EXPECT_*` (continue on fail) for most checks, `ASSERT_*` (abort) for preconditions.
- Register tests in CMake with `add_test()` or `gtest_discover_tests()`.
- Run tests: `cmake --build build --target test` or `ctest --test-dir build`.
- Test edge cases: null/empty input, boundary values, error paths, resource cleanup.
