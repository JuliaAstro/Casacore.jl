# Casacore.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaastro.org/Casacore/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaastro.github.io/Casacore.jl/dev)

[![Test](https://github.com/JuliaAstro/Casacore.jl/actions/workflows/test.yml/badge.svg)](https://github.com/JuliaAstro/Casacore.jl/actions/workflows/test.yml)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/C/Casacore.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
[![Coverage](https://codecov.io/gh/juliaastro/Casacore.jl/graph/badge.svg)](https://codecov.io/gh/juliaastro/Casacore.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This package provides a Julia interface to the National Radio Astronomy Observatory (NRAO) casacore C++ library.

[casacore](https://casacore.github.io/casacore/) is a popular library used primarily in radio astronomy. Amongst other things, its tables functionality is used to store and manipulate visibility data, whilst its measures interface allows for conversion between different reference frames based on ephemeris data.

The Casacore package depends on the [casacorecxx](https://github.com/JuliaBinaryWrappers/casacorecxx_jll.jl) and [CxxWrap](https://github.com/JuliaInterop/CxxWrap.jl) packages to provide a C interface to the casacore C++ library.

This package is still under development. Because casacore is a very large library, the Julia interface has been developed with specific use cases in mind, limited by the author's own experience. Issues and pull requests are very welcome to help expand on functionality and use cases.

## Installation

Casacore.jl is installable in the usual way:

```julia-repl
] add Casacore
```

Casacore.jl will install all of its own dependencies including Casacore itself.

Casacore.jl is limited to the currently supported architectures of `casacore_jll`.

## Updating the ephemeris data

When installing Casacore.jl, the build step downloads and installs the latest ephemeris data for use in `Casacore.Measures`. To update this dataset with a later version, the build step can be manually rerun:

```julia-repl
] build Casacore
```

## Casacore.LibCasacore

All objects and methods that are exposed by CxxWrap are available in LibCasacore. This is not a stable API and may be subject to change.
