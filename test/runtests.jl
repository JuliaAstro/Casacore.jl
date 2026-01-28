using ParallelTestRunner: runtests, find_tests, parse_args
using Casacore

const init_code = quote
    using Casacore.LibCasacore
    using Test
    using Unitful
end

args = parse_args(Base.ARGS)
testsuite = find_tests(@__DIR__)

runtests(Casacore, args; testsuite, init_code)

# Force GC of table objects and their associated flush() to disk
# before tempdirs are removed
GC.gc(true)
