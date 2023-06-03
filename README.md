
# Kiri Pull Request GitHub Action

This is a convenient and easy way to run [Kiri](https://github.com/leoheck/kiri) against a Pull Request using GitHub Actions.

The base Kiri image is hosted in the GitHub Container Repository here <https://github.com/USA-RedDragon/kiri-github-action/pkgs/container/kiri>,
which is based on the Kiri image at <https://github.com/leoheck/kiri-docker>

## Action inputs

All inputs are **optional**.

|           Name           |                               Description                                |
| ------------------------ | ------------------------------------------------------------------------ |
| `all`                    | If set, include all commits even if schematics/layout don't have changes |
| `last`                   | Show last N commits                                                      |
| `newer`                  | Show commits up to this one                                              |
| `older`                  | Show commits starting from this one                                      |
| `skip-cache`             | If set, skip usage of -cache.lib on plotgitsch                           |
| `skip-kicad6-schematics` | If set, skip ploting Kicad 6 schematics (.kicad.sch)                     |
| `force-layout-view`      | If set, force starting with the Layout view selected                     |
| `pcb-page-frame`         | If set, disable page frame for PCB                                       |
| `archive`                | If set, archive generated files                                          |
| `remove`                 | If set, remove generated folder before running it                        |
| `output-dir`             | If set, change output folder path/name                                   |
| `project-file`           | Path to the KiCad project file                                           |
| `extra-args`             | Extra arguments to pass to Kiri                                          |
| `kiri-debug`             | If set, enable debugging output                                          |
| `kiri-tag`               | If set, overrides kiri container tag                                     |

## Examples

```yaml
# .github/workflows/pr-kicad-diff.yaml
name: KiCad Diff Check

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

on:
  pull_request:
    paths:
    - kicad/*.kicad_pcb
    - kicad/*.kicad_sch
    - kicad/*.kicad_pro
    - .github/workflows/pr-kicad-diff.yaml

jobs:
  kiri:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        ref: ${{ github.event.pull_request.head.sha }}
    - name: Kiri
      uses: usa-reddragon/kiri-github-action@v1
```

## TODOs

- Can we push diff images from the generated files to the PR? Failing that, can we make the generated files browsable from a link in the PR?

## Dev note

Make sure to bump versions by both tagging and in `action.yml`: `uses: docker://ghcr.io/usa-reddragon/kiri:<version>`.
