# SeaScanner

SeaScanner is an extended StackUxV software project for marine scanning,
mapping, and perception components. It is organized for reusable libraries,
MOOS applications, and standalone daemon programs.

## Structure

- `src/lib`: reusable SeaScanner libraries
- `src/moos`: MOOS applications
- `src/daemon`: standalone services and utilities

## Build

SeaScanner expects the core `StackUxV` repository to be located beside this
repository. MOOS-IvP may be provided as a sibling source tree or as an
installed package.

```bash
./build.sh -j4
```

Build outputs are written to `bin/`, `lib/`, and `include/`.
