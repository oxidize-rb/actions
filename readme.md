# ⚡️ Ruby on Rust GitHub Actions

This repo contains a collection of GitHub Actions for your Ruby on Rust projects.

## 📦 Actions

### `oxidize-rb/actions/setup-ruby-and-rust@v1`

A GitHub Action that sets up a Ruby environment and Rust environment for use
testing native Rust gems.

[📝 Read the Docs](./setup-ruby-and-rust/readme.md)

### `oxidize-rb/actions/cross-gem@v1`

A GitHub action to cross-compile a Ruby gem for multiple platforms using
`rb-sys-dock`.

[📝 Read the Docs](./cross-gem/readme.md)

### `oxidize-rb/actions/fetch-ci-data@v1`

A GitHub Action to query useful CI data for usage in a matrix, etc.

[📝 Read the Docs](./fetch-ci-data/readme.md)

### `oxidize-rb/actions/cargo-binstall@v1`

A GitHub action to download and install binaries using `cargo-binstall`.

[📝 Read the Docs](./cargo-binstall/readme.md)

### `oxidize-rb/actions/post-run@v1`

Simple action to run a command after a job has finished.

[📝 Read the Docs](./post-run/readme.md)
