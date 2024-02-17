# ⚡️ `oxidize-rb/setup-ruby-and-rust`

A GitHub Action that sets up a Ruby environment and Rust environment for use
testing native Rust gems.

## Example usage

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
        ruby: ["2.7", "3.0", "3.1", "head"]
        rust: ["stable", "beta"]
    steps:
      - uses: actions/checkout@v4

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

## Inputs

<!-- inputs -->

| Name                       | Description                                                                                                                                                 | Default           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| **bundler-cache**          | Run "bundle install", and cache the result automatically. Either true or false.                                                                             | `false`           |
| **cache-version**          | Arbitrary string that will be added to the cache key of the bundler cache. Set or change it if you need to invalidate the cache.                            | `v0`              |
| **cargo-cache**            | Strategy to use for caching build artifacts (either 'sccache', 'tarball', or 'false')                                                                       | `default`         |
| **cargo-cache-clean**      | Clean the cargo cache with cargo cache --autoclean                                                                                                          | `true`            |
| **cargo-cache-extra-path** | Paths to cache for cargo and gem compilation                                                                                                                |                   |
| **cargo-vendor**           | Vendor cargo dependencies to avoid repeated downloads                                                                                                       | `false`           |
| **debug**                  | Enable verbose debugging info (includes summary of action)                                                                                                  | `false`           |
| **ruby-version**           | Engine and version to use, see the syntax in the README. Reads from .ruby-version or .tool-versions if unset. Can be set to 'none' to skip installing Ruby. | `default`         |
| **rubygems**               | Runs `gem update --system`. See https://github.com/ruby/setup-ruby/blob/master/README.md for more info.                                                     | `default`         |
| **rustup-components**      | Comma-separated string of additional components to install e.g. clippy, rustfmt                                                                             | `clippy, rustfmt` |
| **rustup-targets**         | Comma-separated string of additional targets to install e.g. wasm32-unknown-unknown                                                                         |                   |
| **rustup-toolchain**       | Rustup toolchain specifier e.g. stable, nightly, 1.42.0, nightly-2022-01-01.                                                                                | `stable`          |
| **working-directory**      | The working directory to use for resolving paths for .ruby-version, .tool-versions and Gemfile.lock.                                                        |                   |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name              | Description                                   |
| ----------------- | --------------------------------------------- |
| **cache-key**     | Derived cache key for the current environment |
| **ruby-platform** | The platform of the installed ruby            |
| **ruby-prefix**   | The prefix of the installed ruby              |

<!-- /outputs -->
