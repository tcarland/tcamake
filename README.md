tcamake
=======

***Author***  tcarland@gmail.com  
***Version***  23.08


## Overview:

**tcamake** is a Gnu automake build environment for code projects.
It is not its own 'make' implementation. It simply wraps the use of
Gnu 'automake' providing preset platform specific dependencies and
environments.

The goal is to provide a clean and simplified method of managing large
project and sub-project dependencies in a common set of configurations
which allows for cleaner and logical *Makefile*s.  

The system has been used reliably for years and serves as my excuse to
avoid the GNU autoconf toolset when possible. While certainly not as
powerful as the autoconf, the Makefile template hierarchy lends itself nicely
as a build system mechanism or even in addition to the gnu autotools. It is
surprisingly capable and even useful for managing a build environment
for very large projects and multiple platforms.

**tcamake** provides an *include* hierarchy that defines all of the
dependencies of projects within the build system.

## Layout (TCAMAKE_PROJECT):

The build environment layout is specific to a directory structure starting 
with a root directory that is referred to as the *Project* directory or
`TCAMAKE_PROJECT`. This can be for a single project or group of projects as 
needed.  The term *Project* is used to define an encompassing environment
that may contain many sub-projects and can be also thought of as a *workspace*.

An instance of the *tcamake* build environment should exist at the project 
workspace level or otherwise have TCAMAKE_HOME set accordingly.

A given workspace project may consist of many sub-projects or repositories 
that consist of dependencies. Each of these projects can refer to the build 
system via *TCAMAKE_HOME* and any given project Makefile should always include 
*${TCAMAKE_HOME}/tcamake_include*. The include should occur **after** setting
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
OPT_FLAGS= 	-g
endif

CCSHARED +=  -Wl,-soname,$@
CXXFLAGS =   -std=c++11

INCLUDES=   -Iinclude
LIBS=

# objects
BIN=		mybin
OBJS=		src/mysrc.o

ALL_OBJS=	$(OBJS)
ALL_BINS=	$(BIN)

# Include tcamake after all custom defines
# ---------------

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
and can be modified as needed. A given project can then have a default
Makefile template installed by using the project init script:
*tcamake_init_project.sh*.  


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
  An internal file for defining build 14sommands and is the last file included
  by 'depends'. This file should NOT need to be modified.


## Scripts:

A few scripts simply to assist in building or initializing projects.
They make use of the Makefile templates found in the 'tcamake/template'
directory which also serve as good examples.   

The build script is intended to be useful in creating project
distributions suitable for export ensuring common dependencies are linked
within a given project as needed.  

- **tcamake_build.sh**  
  Some projects within the workspace may wish to be exported or built
  independently of the workspace. This script will assist in creating a
  project distribution by ensuring that links for needed dependencies
  such as 'tcamake' itself or other common libs are generated.

- **tcamake_init_project.sh**  
  Used to inititiate a new project within the workspace, providing
  a base Makefile template.
