# ⚡️ Ruby on Rust GitHub Actions

This repository features a curated suite of GitHub Actions designed for Ruby on Rust projects, making it easier to set up and test native Rust gems within Ruby environments.

## 📦 Available Actions

### Setup Ruby and Rust (`oxidize-rb/actions/setup-ruby-and-rust@v1`)

⚙️ A GitHub Action that prepares both Ruby and Rust environments, aimed at facilitating the testing of native Rust gems.

- [📝 Documentation](./setup-ruby-and-rust/readme.md)

### Cross-Compile Ruby Gems (`oxidize-rb/actions/cross-gem@v1`)

🌍 This action enables the cross-compilation of Ruby gems for various platforms using `rb-sys-dock`, enhancing the accessibility of Ruby gems across different systems.

- [📝 Documentation](./cross-gem/readme.md)

### Fetch CI Data (`oxidize-rb/actions/fetch-ci-data@v1`)

🔍 Retrieves essential Continuous Integration (CI) data, useful for optimizing CI matrix configurations and other automated processes.

- [📝 Documentation](./fetch-ci-data/readme.md)

### Cargo Binary Installer (`oxidize-rb/actions/cargo-binstall@v1`)

📦 Simplifies downloading and installing binaries with `cargo-binstall`, streamlining the integration of Rust binaries into projects.

- [📝 Documentation](./cargo-binstall/readme.md)

### Post-Run Command (`oxidize-rb/actions/post-run@v1`)

🏁 A concise action for executing commands post-job completion, assisting in clean-up or further setup steps.

- [📝 Documentation](./post-run/readme.md)
