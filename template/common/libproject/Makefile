#  tcamake template for a common library
#

# this ifdef allows the library to be a standalone distribution
# (this requires ./tcamake/ to exist (use a symlink)
#
ifndef TOPDIR
  TOPDIR = ../..
endif

# build requirements
NEED_PTHREADS = 1
NEED_LIBDL = 1

#-------------------#

ifdef TCAMAKE_DEBUG
  OPT_FLAGS = -g
endif

OPT_FLAGS +=	    -fPIC -O2
CCSHARED  +=	    -Wl,-soname,$@
CXXFLAGS   =        -std=c++0x

# custom include/libs
INCLUDES =	    -Iinclude
LIBS =

OBJS =		    src/mylib.o
TEST_OBJS =	    src/test.o
                    
BIN =		    mylibtest
ALL_OBJS =	    $(OBJS) $(TEST_OBJS) 
ALL_BINS = 	    $(BIN)


all: lib

# REQUIRED
include ${TOPDIR}/tcamake/project_defs


lib: arlib solib

arlib: lib/libmylib.a

solib: lib/libmylib.so.0.0.1

lib/libmylib.a: ${OBJS}
	( $(MKDIR) lib )
	$(make-lib-rule)
	@echo

lib/libmylib.so.0.0.1: ${OBJS}
	( $(MKDIR) lib )
	( $(RM) $@ lib/libmylib.so )
	$(make-so-rule)
	( mv $@ lib/; cd lib; ln -s $@ libmylib.so )
	@echo

documentation:
	(cd docs; ${MAKE} ${MFLAGS} ${MVARS} all )
	@echo

libclean:
	rm -rf lib
	@echo

docclean:
	( cd docs; $(MAKE) clean )
	@echo

clean:
	$(RM) $(ALL_OBJS) \
	src/*.d src/*.D src/*.bd src/*.o lib/*.bd *.bd
	@echo
	
testclean:
	( cd test; $(MAKE) distclean )
	@echo

distclean: clean libclean docclean testclean
	$(RM) $(ALL_BINS)
	@echo

dist:
ifdef DISTDIR
	@echo "sync'ing to $(DISTDIR)/mylib"
	( make distclean; $(RDIST) ./ $(DISTDIR)/ )
	@echo
endif

install:
ifdef TCAMAKE_PREFIX
	@echo "Installing mylib to $(TCAMAKE_PREFIX)/lib"
	$(RSYNC) --delete include/ $(TCAMAKE_PREFIX)/include/mylib/
	$(RSYNC) lib/ $(TCAMAKE_PREFIX)/lib/
endif

