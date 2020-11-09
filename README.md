tcamake
=======

***Author***  tcarland@gmail.com  
***Version***  20.11.1


### Overview:

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

### Layout (TOPDIR):

  The build environment layout is specific to a directory structure
starting with a root directory that is referred to as the 'top' directory
or $TOPDIR. This can be for a single project or group of projects as needed.
The term project is used loosely to define an encompassing environment
that may, in fact, contain many sub-projects and is frequently referred 
to as a 'workspace'.

  An instance of the *tcamake* build environment should exist at the 
workspace top-level. For example, assume we have the following workspace, 
*~/src/repo* where `repo` is considered the workspace or TOPDIR. The build 
system would then be `$TOPDIR/tcamake` or in this case, *~/src/repo/tcamake*.  

  Individual code projects in the workspace such as a top-level project 
(eg. *~/src/repo/project_a*) would define *TOPDIR* simply as `..`. Each 
subsequent project Makefile would define this *TOPDIR* environment variable 
as pointing to the relative root of the workspace.

  Additionally, each Makefile must include *$TOPDIR/tcamake/tcamake_include*,
though this should include should occur **after** setting any custom
options as shown in the below example:
```
TOPDIR = ..

# requirements
NEED_SOCKET = 1
NEED_ZLIB = 1
NEED_KAFKA = 1

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

include $(TOPDIR)/tcamake/tcamake_include

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

  The environment variable **TCAMAKE_PROJECT** can be used for defining 
dependencies that should be resolved locally or relative to the workspace 
*TOPDIR*. This allows us to override dependency versions that may also be 
found in the system paths  (eg. openssl libraries). 


### Files:

The Makefile hierarchy includes the following files:


 * **tcamake_include**  
    This is the Makefile *include* file to be included by a Makefile.
    It pulls in both the dependencies and the platform environment via the
    'depends' and 'environment' files respectively and is the entrypoint.

 * **tcamake.Makefile**  
    This is the primary *include* file of the tcamake framework. This gets 
    included by *tcamake_include* which is the entrypoint as described above.

 * **tcamake_env**  
    This is included automatically for each project to initiate the
    platform's desired compiler flags and other platform specific macros.
    This file should NOT need to be modified other than to add new
    platform environment profiles.

 * **tcamake_depends**  
    The file for defining all project dependencies. This is the only file
    that should need updating. Since these dependencies generate our 
    compile-time **INCLUDE** and **LIB** variables, order can be important.  
    As a general rule, the order should sort projects with the most 
    dependencies before projects with the least dependencies.  

 * **tcamake_autodepend**  
    An internal file for defining build commands and is the last file included
    by 'depends'. This file should NOT need to be modified.


### Scripts:

  A few scripts simply to assist in building or initializing projects.
They make use of the Makefile templates found in the 'tcamake/template'
directory which also serve as good examples.   
  The build script is intended to be useful in creating project
distributions suitable for export ensuring common dependencies are linked
within a given project as needed.  

 * **tcamake_build.sh**  
    Some projects within the workspace may wish to be exported or built
    independently of the workspace. This script will assist in creating a
    project distribution by ensuring that links for needed dependencies
    such as 'tcamake' itself or other common libs are generated.
    Alternatively, it simply allows for building a project
    while overriding TOPDIR.

 * **tcamake_init_project.sh**  
    Used to inititiate a new project within the workspace, providing
    a base Makefile template.
