# ⚡️ `oxidize-rb/setup-ruby-and-rust`

A GitHub Action that sets up a Ruby environment and Rust environment for use
testing native Rust gems.

#### Example usage

```yaml
---
name: CI

on:
  push:
    branches:
      - main

  pull_request:

jobs:
  ci:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: ["ubuntu-latest", "macos-latest", "windows-latest"]
        ruby: ["2.6", "2.7", "3.0", "3.1", "head"]
        rust: ["stable", "beta"]
    steps:
      - uses: actions/checkout@v3

      - uses: oxidize-rb/actions/setup-ruby-and-rust@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          rustup-toolchain: ${{ matrix.rust }}
          bundler-cache: true
          cargo-cache: true

      - name: Run ruby tests
        run: bundle exec rake

      - name: Lint rust
        run: cargo clippy && cargo fmt --check
```
