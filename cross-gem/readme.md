# ⚡️ `oxidize-rb/actions/cross-gem`

A GitHub action to cross-compile a Ruby gem for multiple platforms using
`rb-sys-dock`.

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
          platform: ${{ matrix.platform }}
          ruby-versions: ${{ join(fromJSON(needs.ci-data.outputs.result).stable-ruby-versions, ',') }}

      - uses: actions/upload-artifact@v4
        with:
          name: cross-gem-${{ matrix.platform }}
          path: ${{ steps.cross-gem.outputs.gem-path }}
```

## Inputs

<!-- inputs -->

| Name                  | Description                                                                                                                      | Default   |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- | --------- |
| **cache-save-always** | Whether to save the cache even if the build fails.                                                                               | `true`    |
| **cache-version**     | Arbitrary string that will be added to the cache key of the bundler cache. Set or change it if you need to invalidate the cache. | `v0`      |
| **cargo-cache-clean** | Whether to clean the cargo cache after the build.                                                                                | `true`    |
| **platform**          | The platform to cross-compile for (e.g. `x86_64-linux`)                                                                          |           |
| **ruby-versions**     | The Ruby versions to cross-compile for (e.g. `2.7,3.0,3.1`)                                                                      | `default` |
| **tag**               | The docker tag to use for the `rb-sys` images.                                                                                   | `default` |
| **working-directory** | The working directory to run the action in.                                                                                      | `.`       |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name         | Description                        |
| ------------ | ---------------------------------- |
| **gem-path** | The path to the cross-compiled gem |

<!-- /outputs -->
