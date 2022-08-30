#
#  @file tcamake.Makefile
#  @AUTHOR Timothy C. Arland <tcarland@gmail.com>
#
#  Global compile options and dependency definitions. Including this file
#  pulls in dependencies via 'tcamake_env' and namely 'tcamake_depends'.
#
export TCAMAKE_VERSION="v22.08"

ifndef TCAMAKE_ENV
    include $(TOPDIR)/tcamake/tcamake_env
endif

#-------------------------------------------------------------------------

RM = rm -rf
CP = cp --preserve
MKDIR = mkdir -p
RSYNC = rsync -av
RDIST = rsync -avL --delete --exclude=.git --exclude=.svn --exclude=.cvs
PANDOC = pandoc -s

CXX = g++
CC  = gcc

ifdef AFL_DEBUG
  CXX = afl-g++
  CC  = afl-gcc
endif

DEP_OBJS = *.d *.D *.bd src/*d src/*.D src/*.bd

ifndef OPT_FLAGS
  OPT_FLAGS = -O2
endif

ifndef CPPFLAGS
  CPPFLAGS = -Wall ${INCLUDES} ${MACROS}
endif

ifndef CPPFLAGS_THR
  CPPFLAGS_THR	= -DUSE_PTHREADS
endif

ifndef CFLAGS
  CFLAGS = $(OPT_FLAGS)
else
  CFLAGS += $(OPT_FLAGS)
endif

ifdef L_OBJS
  ALL_OBJS += $(L_OBJS)
ifdef L_TARGET
    LIBS += $(L_TARGET)
endif
endif

ifdef T_TARGETS
  ALL_OBJS += $(T_TARGETS:=.o)
  ALL_BINS += $(T_TARGETS)
endif

ifdef TXX_TARGETS
  ALL_OBJS += $(TXX_TARGETS:=.o)
  ALL_BINS += $(TXX_TARGETS)
endif

ifndef PDFLAGS
    PDFLAGS = -V geometry:margin=1in -f markdown-implicit_figures
endif

#-------------------------------------------------------------------------
# Do not edit below this line
ifndef TCAMAKE_DEPENDS
  include $(TOPDIR)/tcamake/tcamake_depends
endif
