# Zig Build System Examples

This repository demonstrates how to use Zig's build system to integrate and link code written in Zig, C, and Rust. Each example shows how to build and call functions across language boundaries using Zig's build scripting and FFI capabilities.

## Rust FFI with Zig

- The Rust library is defined in [`lib/rustlib`](lib/rustlib), with the main function `rust_add` exported using `#[no_mangle]` and `extern "C"`.
- The Rust static library is built using Cargo and static linked into a Zig executable.
- The Zig entry point is [`src/main_rust.zig`](src/main_rust.zig), which declares the Rust function as `extern` and calls it.
- The Rust header file [`rustlib_wrapper.h`](lib/rustlib/rustlib_wrapper.h) is used for C ABI compatibility.

> Note: In Zig, `addLibrary` is used to define a Zig package as a library. For Rust libraries, since Cargo already builds the library, there’s no need to call `addLibrary` again to wrap the .a or .o libray again. Doing so may cause mismatches with the exported Rust symbols.

## C FFI with Zig

- The C library is defined in [`lib/clib`](lib/clib), with the function `cmark_add` implemented in C and declared in a header file.
- The C source is compiled and linked into a Zig executable.
- The Zig entry point is [`src/main_c.zig`](src/main_c.zig), which declares the C function as `extern` and calls it.

## Link Zig as a Static Library

- The Zig library is defined in [`lib/ziglib/zig_add.zig`](lib/ziglib/zig_add.zig) and exported as a static library.
- The Zig executable [`src/main_zig.zig`](src/main_zig.zig) links against this library and calls the exported function.

## Building

To build all examples, simply run:

```sh
zig build
```

This will:
- Build and link the Rust static library, then build the Zig executable that calls into Rust.
- Build and link the C static library, then build the Zig executable that calls into C.
- Build the Zig static library and the Zig executable that uses it.

## Project Structure

```
src/
  main_c.zig      # Zig executable calling C
  main_rust.zig   # Zig executable calling Rust
  main_zig.zig    # Zig executable calling Zig static lib

lib/
  clib/
    cmark_add.c   # C implementation
    cmark_add.h   # C header
  rustlib/
    src/lib.rs    # Rust implementation
    rustlib_wrapper.h # Rust-generated C header
    Cargo.toml    # Rust build config
  ziglib/
    zig_add.zig   # Zig static library
```

## Notes

- The build script [`build.zig`](build.zig) demonstrates how to orchestrate multi-language builds and link steps using Zig's build DSL.
- For Rust FFI, ensure you have Rust and Cargo installed.
- For C FFI, a C compiler is required (Zig can act as one).
- Use `nm -g zig-out/lib/libzigadd.a` to verify that the functions are exported in the library object file.
- Use `readelf -h zig-out/lib/libzigadd.a` to check the ELF file headers.
- Use `ar t zig-out/lib/libzigadd.a` to see what's linked in the archive file.

## Supported Zig Versions
Zig evolves quickly, so the main repo will aim to stay up to date with the latest releases.  
For older build examples, please check the tags.  
- `0.15.1`

## TODO
- [ ] Add Go FFI example
- [ ] Add C++ FFI example
- [ ] Examples for Go/C/Rust/C++ to call Zig