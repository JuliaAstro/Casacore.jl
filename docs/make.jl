using Casacore
using Documenter: makedocs, HTML, deploydocs
using Documenter.Remotes: GitHub

makedocs(;
    sitename = "Casacore.jl",
    modules = [Casacore],
    authors = "Torrance Hodgson <torrance@pravic.xyz>, Kiran Shila <me@kiranshila.com>, Fergus Baker <fergus@cosroe.com>, Paul Barrett <pebarrett@gmail.com>",
    repo = GitHub("JuliaAstro/Casacore.jl"),
    format = HTML(;
        canonical = "https://juliaastro.org/Casacore/stable/",
    ),
    pages = [
        "Home" => "index.md",
    ],
    doctest = false,
    linkcheck = true,
    warnonly = [:missing_docs, :linkcheck],
)

in_CI_env = get(ENV, "CI", "false") == "true"

if in_CI_env
    deploydocs(;
        repo = "github.com/JuliaAstro/Casacore.jl",
        versions = ["stable" => "v^", "v#.#"], # Restrict to minor releases
        push_preview = true,
    )
end
