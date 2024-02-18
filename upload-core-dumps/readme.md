# ⚡️ `oxidize-rb/actions/upload-core-dumps`

This GitHub Action automatically configures your runner to capture and upload
core dumps, making debugging easier across Linux, macOS, and Windows (maybe).

## Notes

- This action attempts to infer crashing executable, but if that fails for some
  reason you can manually upload using the `extra-files-to-upload` option
- Core dumps larger than 50GiB will be ignored

## Example usage

```yaml
name: Test

on: push

jobs:
  test:
    runs-on: ubuntu-latest
      - uses: actions/checkout@v4

      - uses: oxidize-rb/actions/upload-core-dumps@v1
        with:
          extra-files-to-upload: |
            /usr/lib/whatever.so

      - run: |
          # IMPORTANT: this required to enable core dumps and must be done in each step
          ulimit -c unlimited

          # Core dump will be uploaded as an artifact
          ./some-crashing-binary
```

## Inputs

<!-- inputs -->

| Name                      | Description                | Default |
| ------------------------- | -------------------------- | ------- |
| **extra-files-to-upload** | A list of files to upload. |         |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name | Description |
| ---- | ----------- |

<!-- /outputs -->
