MTL       = ../mtl
CHDRS     = $(wildcard *.h) $(wildcard $(MTL)/*.h)
EXEC      = minisat
CFLAGS    = -I$(MTL) -std=c++11 -Wall -ffloat-store $(EXTRACFLAGS)
LFLAGS    = -lz

include ../mtl/template.mk
