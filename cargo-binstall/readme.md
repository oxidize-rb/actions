# ⚡️ `oxidize-rb/cargo-binstall`

A GitHub action to download and install binaries using `cargo-binstall`.

## Example usage

### `stable-ruby-versions`

```yaml
name: Test

on: push

jobs:
  wasmtime:
    name: Install Wasmtime
    runs-on: ubuntu-latest
    steps:
      - uses: "oxidize-rb/actions/cargo-binstall@v1"
        with:
          name: "wasmtime-cli"
          version: "4.0.0"
```

## Inputs

<!-- inputs -->

| Name        | Description             | Default |
| ----------- | ----------------------- | ------- |
| **crate**   | The crate to install.   |         |
| **version** | The version to install. |         |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name       | Description                     |
| ---------- | ------------------------------- |
| **status** | The status of the installation. |

<!-- /outputs -->
