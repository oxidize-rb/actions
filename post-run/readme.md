# ⚡️ `oxidize-rb/actions/post-run`

Simple action to run a command after a job has finished.

## Example usage

```yaml
name: Test

on: push

jobs:
  test:
    runs-on: ubuntu-latest
      - uses: actions/checkout@v4
      - uses: oxidize-rb/actions/post-run@v1
        with:
          run: cargo cache --autoclean
```

## Inputs

<!-- inputs -->

| Name       | Description                                                 | Default                                   |
| ---------- | ----------------------------------------------------------- | ----------------------------------------- |
| **always** | Always run, even if the job fails.                          | `false`                                   |
| **cwd**    | A working directory from which the command needs to be run. |                                           |
| **run**    | A command that needs to be run.                             | `echo "This is a post-action command..."` |

<!-- /inputs -->

## Outputs

<!-- outputs -->

| Name | Description |
| ---- | ----------- |

<!-- /outputs -->
