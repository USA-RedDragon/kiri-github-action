
# Kiri Pull Request GitHub Action

This is a convenient and easy way to run [Kiri](https://github.com/leoheck/kiri) against a Pull Request using GitHub Actions.

The base Kiri image is hosted in the GitHub Container Repository here <https://github.com/USA-RedDragon/kiri-github-action/pkgs/container/kiri>,
which is based on the Kiri image at <https://github.com/leoheck/kiri-docker>

## PR HTML Preview Setup

In order to provide PRs with a link to preview the changes, this action pushes to the `gh-pages` branch of the source
repository and hosts the Kiri output in subdirectories.

For this to work properly, you'll need to make an empty `gh-pages` branch with the file `.nojekyll` (to avoid `_KIRI_` folders returning a 404).

### Deleting PRs on close

Running this action in the context of `pull_request.closed` will delete any Kiri previews that were made for the PR.

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
    - '*.kicad_pcb'
    - '*.kicad_sch'
    - '*.kicad_pro'

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

```yaml
# .github/workflows/pr-kicad-diff-delete.yaml
name: KiCad Diff Delete

on:
  pull_request:
    types:
    - closed

jobs:
  kiri:
    runs-on: ubuntu-latest
    steps:
    - name: Kiri
      uses: usa-reddragon/kiri-github-action@v1
```
