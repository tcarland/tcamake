TOPDIR = ../..

ifeq (, $(shell which pandoc))
 $(error "Error, 'pandoc' not found in PATH.")
endif

sources:=$(wildcard *.md)
objects:=$(patsubst %.md,%.pdf,$(sources))

all: pdf documentation

include $(TOPDIR)/tcamake/project_defs

documentation:
	( doxygen )

pdf: $(objects)

clean:
	( $(RM) *.pdf html latex )