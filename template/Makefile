# ------------------------
#  Top-level Makefile
#
include ./build_env

# ------------------------

all: print-env external common project

print-env:
	@uname -a
	@echo
	@gcc -v
	@echo

.PHONY: common
common:
	( cd common; make all )
	@echo

.PHONY: project
project:
	( cd project; make all )
	@echo

external:
	( cd common/ext; ./build_extlibs.sh )
	@echo

external-clean:
	( cd common/ext; make distclean )
	@echo

clean:
	( cd common; make clean )
	( cd project; make clean )
	@echo

distclean: external-clean
	( cd common; make distclean )
	( cd project; make distclean )
	@echo

install:
ifdef TCAMAKE_PREFIX
	( cd common; make install )
	( cd project; make install )
	@echo
endif
