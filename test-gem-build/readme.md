# ⚡️ `oxidize-rb/test-gem-build`

A GitHub action to test whether your Ruby on Rust gem built successfully.

## Example usage

```yaml
---
name: CI

on:
  push:
    tags:
      - "v*"

jobs:
  ci-data:
    runs-on: ubuntu-latest
    outputs:
      result: ${{ steps.fetch.outputs.result }}
    steps:
      - uses: oxidize-rb/actions/fetch-ci-data@v1
        id: fetch
        with:
          supported-ruby-platforms: |
            exclude: [arm-linux]
          stable-ruby-versions: |
            exclude: [head]
  cross-gem:
    name: Compile native gem for ${{ matrix.platform }}
    runs-on: ubuntu-latest
    needs: ci-data
    strategy:
      matrix:
        platform: ${{ fromJSON(needs.ci-data.outputs.result).supported-ruby-platforms }}
    steps:
      - uses: actions/checkout@v2

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.1"

      - uses: oxidize-rb/actions/cross-gem@v1
        id: cross-gem
        with:
          platform: ${{ matrix.ruby-platform }}
          ruby-versions: ${{ join(fromJSON(needs.ci-data.outputs.result).stable-ruby-versions, ',') }}

      - uses: oxidize-rb/actions/test-gem-build@main
        with:
          platform: ${{ matrix.ruby-platform }}
          ruby-versions: ${{ join(fromJSON(needs.ci-data.outputs.result).stable-ruby-versions, ',') }}
```

## Inputs

<!-- inputs -->

| Name              | Description                                                             | Default   |
| ----------------- | ----------------------------------------------------------------------- | --------- |
| **platform**      | The platform which the gem was cross-compiled for (e.g. `x86_64-linux`) |           |
| **ruby-versions** | The Ruby versions the gem was cross-compiled for (e.g. `2.7,3.0,3.1`)   | `default` |

<!-- /inputs -->
