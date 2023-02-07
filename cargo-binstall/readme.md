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

| Name             | Description                       | Required | Default   |
| ---------------- | --------------------------------- | -------- | --------- |
| **crate**        | The crate to install.             | Yes      |           |
| **install-path** | The path to install the crate to. | No       | `default` |
| **strategies**   | The strategies to use.            | No       | `default` |
| **version**      | The version to install.           | Yes      |           |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name       | Description                     | Required |
| ---------- | ------------------------------- | -------- |
| **status** | The status of the installation. | No       |

<!-- /outputs -->
