# Makefile
#
#   Template Makefile for projects
#

# set requirements
NEED_SOCKET = 1
NEED_ZLIB = 1

ifdef MYPROJECT_DEBUG
OPT_FLAGS= 	-g
endif

# custom lib/includes
INCLUDES=       -Iinclude
LIBS=

BIN=		mybin
OBJS=		src/mysrc.o

ALL_OBJS=	$(OBJS)
ALL_BINS=	$(BIN)

# ---------------------------------------------

ifeq ($(TCAMAKE_HOME),)
	export TCAMAKE_HOME := $(shell realpath ../tcamake)
endif
ifeq ($(TCAMAKE_PROJECT),)
	export TCAMAKE_PROJECT := $(shell realpath ..)
endif

include ${TCAMAKE_HOME}/tcamake_include

# ---------------------------------------------


all: mybin

mybin: $(OBJS)
	$(make-cxxbin-rule)
	@echo

.PHONY: test
test:

clean:
	$(RM) $(ALL_OBJS) \
	*.d *.D *.o src/*.d src/*.D src/*.bd src/*.o
	@echo

distclean: clean
	$(RM) $(ALL_BINS)
	@echo

install:
ifdef PROJECT_PREFIX
	@echo
endif
