# ⚡️ `oxidize-rb/fetch-ci-data`

A GitHub action to query useful CI data for Ruby on Rust.

## Example usage

### `stable-ruby-versions`

Use this action to generate a matrix based on Ruby's published CI versions. By
default, this action will select all "stable" Ruby versions, with one catch...

As it gets closer to December 25th (i.e. next Ruby major), this action will
start opting in to `ruby-head` builds by default. The goaal is to find a happy
medium of stability + future preparedness. If you don't like that, or builds
start failing, you can manually `exclude: [head]`.

```yaml
name: Test

on: push

jobs:
  ci-data:
    runs-on: ubuntu-latest
    outputs:
      result: ${{ steps.fetch.outputs.result }}
    steps:
      - id: fetch
        uses: oxidize-rb/actions/fetch-ci-data@v1
        with:
          stable-ruby-versions: |
            exclude: []
  test:
    name: Test on Ruby ${{ matrix.ruby }}
    needs: ci-data
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ruby: ${{ fromJSON(needs.ci-data.outputs.result).stable-ruby-versions }}
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
      - run: bundle exec rake
```

### `supported-ruby-platforms`

```yaml
name: Test

on: push

jobs:
  ci-data:
    runs-on: ubuntu-latest
    outputs:
      result: ${{ steps.fetch.outputs.result }}
    steps:
      - id: fetch
        uses: oxidize-rb/actions/fetch-ci-data@v1
        with:
          supported-ruby-platforms: |
            exclude:
              - x64-mingw32
  native_gem:
    name: Compile native gem
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

      - uses: oxidize-rb/cross-gem-action@v7
        with:
          platform: ${{ matrix.platform }}
          ruby-versions: "3.1, 3.0, 2.7" # optional

      - uses: actions/download-artifact@v3
        with:
          name: cross-gem
          path: pkg/

      - name: Display structure of built gems
        run: ls -R
        working-directory: pkg/
```

## Inputs

<!-- inputs -->

| Name                         | Description                                                               | Default |
| ---------------------------- | ------------------------------------------------------------------------- | ------- |
| **stable-ruby-versions**     | List non-EOF Ruby versions                                                | `true`  |
| **supported-ruby-platforms** | List all supported cross-platforms (can exclude items with YAML argument) | `true`  |
| **supported-rust-targets**   | List all supported Rust targets (can exclude items with YAML argument)    | `true`  |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name       | Description                                                                      |
| ---------- | -------------------------------------------------------------------------------- |
| **result** | Result of the query (i.e. `{"stable-ruby-versions":["2.7","3.0","3.1","head"]}`) |

<!-- /outputs -->
