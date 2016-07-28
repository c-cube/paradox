# Paradox

See [the official page](http://vlsicad.eecs.umich.edu/BK/Slots/cache/www.cs.chalmers.se/~koen/paradox/)
for a description, papers, real authors.

This repository is a copy of the last distribution I could find (from 2010…)
with some changes to make it compile on GHC 7.10.3 and C++11. I also expect to
clean up the code a bit.


## Build

You will need a version of gcc that supports C++11 and probably some flavour
of GMP for GHC to compile.

- install [Stack](https://docs.haskellstack.org/en/stable/README/)
- run `stack setup`
- run `stack init`
- run `stack exec make`

if everything goes well, the binary will be in `src/paradox`.
