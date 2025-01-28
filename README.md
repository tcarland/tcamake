tcamake
=======

***Author***  tcarland@gmail.com  
***Version***  25.01.28


## Overview:

**tcamake** is a Gnu automake build environment for code projects.
It is not its own 'make' implementation. It simply wraps the use of
Gnu 'automake' providing preset platform specific dependencies and
environments.

The goal is to provide a clean and consistent method of managing large
projects with sub-project dependencies in a common set of configurations
which allows for logical *Makefile*s.  

The system has been used reliably for years and serves as an excuse to
avoid the GNU *autoconf* toolset when possible. While certainly not as
powerful as *autoconf*, the Makefile template hierarchy lends itself nicely
as a simple build system mechanism, even when used in conjunction with 
Gnu autotools. It is capable and even useful for managing a build environment
for very large projects and multiple platforms.

**tcamake** provides an *include* hierarchy that defines all of the
dependencies of the projects within the build system.

## Layout (TCAMAKE_PROJECT):

The build environment layout is specific to a directory structure starting 
with a root directory that is referred to as the *Project* directory or
`TCAMAKE_PROJECT`. This can be for a single project or group of projects as 
needed.  The term *Project* is used to define an encompassing environment
that may contain many sub-projects and can be also thought of as a *workspace*.

An instance of the *tcamake* build environment should exist at the project 
workspace level or otherwise have TCAMAKE_HOME set accordingly.

A given workspace project may consist of many sub-projects or repositories 
with dependencies. Each of these projects can refer to the build 
system via *TCAMAKE_HOME* and any given project Makefile should always include 
*${TCAMAKE_HOME}/tcamake_include*. The include must occur **after** setting
various custom options or build overrides such as OPT_FLAGS, CFLAGS or CXXFLAGS,
INCLUDES, LIBS, etc.

The following example demonstrates a typical Makefile layout.
```makefile
# requirements
NEED_SOCKET = 1
NEED_ZLIB = 1
NEED_RDKAFKA = 1

# Custom flags
ifdef TCAMAKE_DEBUG
OPT_FLAGS= -g
endif

CCSHARED+=  -Wl,-soname,$@
CXXFLAGS=   -std=c++11

INCLUDES= -Iinclude
LIBS=

# objects
BIN=		mybin
OBJS=		src/mysrc.o

ALL_OBJS=	$(OBJS)
ALL_BINS=	$(BIN)

# Include tcamake after all custom defines
# ---------------
ifeq($(TCAMAKE_HOME),)
    export TCAMAKE_HOME := $(shell realpath ../tcamake)
endif

include $(TCAMAKE_HOME)/tcamake_include

# ---------------
all: mybin test

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
ifdef TCAMAKE_PREFIX
	@echo "Installing $BIN"
    $(CP) $BIN $TCAMAKE_PREFIX/bin
endif
```

Templates for these Makefiles are provided in the templates sub-directory
and can be modified as needed. 


## Files:

The Makefile hierarchy includes the following files:

- **tcamake_include**  
  This is the Makefile *include* file to be included by a Makefile.
  It pulls in both the dependencies and the platform environment via the
  'depends' and 'environment' files respectively and is the entrypoint.

- **tcamake.Makefile**  
  This is the primary *include* file of the tcamake framework. This gets 
  included by *tcamake_include* which is the entrypoint as described above.

- **tcamake_env**  
  This is included automatically for each project to initiate the
  platform's desired compiler flags and other platform specific macros.
  This file should NOT need to be modified other than to add new
  platform environment profiles.

- **tcamake_depends**  
  The file for defining all project dependencies. This is the only file
  that should need updating. Since these dependencies generate our 
  compile-time **INCLUDE** and **LIB** variables, order can be important.  
  As a general rule, the order should sort projects with the most 
  dependencies before projects with the least dependencies.  

- **tcamake_autodepend**  
  An internal file for defining build commands and is the last file 
  to be included by *tcamke_depends*. This file should NOT need to be 
  modified.
