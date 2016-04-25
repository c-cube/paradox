.NOTPARALLEL:

#-- Variables

MINISAT = src/minisat/current-base
INST    = src/instantiate
HASKELL = src/

#-- Add this when compiling on Cygwin

#-- export EXTRACFLAGS=-mno-cygwin

#-- Main

main: mk-minisat mk-instantiate mk-haskell

clean:
	make clean -C $(HASKELL)
	make clean -C $(MINISAT)

mk-minisat:
	make Solver.or -C $(MINISAT)
	make Prop.or   -C $(MINISAT)

mk-instantiate:
	make MiniSatWrapper.or           -C $(INST)
	make MiniSatInstantiateClause.or -C $(INST)

mk-haskell:
	make -C $(HASKELL)

