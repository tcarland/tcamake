#!/bin/bash
#
#  Initializes a new workspace, source repository, or project root
#  using the 'tcamake' project as template
#
PNAME=${0##*\/}
AUTHOR="tcarland@gmail.com"

BASENAME=
TARGET=
RSYNC="rsync "
OPTIONS="-av"
DRYRUN="n"


usage()
{
    echo ""
    echo "Usage: $PNAME targetpath {dryrun}"
    echo ""
    echo "   Creates a new project workspace or repository"
    echo "   in 'targetpath'"
    echo ""
    echo "   The script must run from within the tcamake "
    echo "   project to be used as the template for the new "
    echo "   workspace"
    echo ""
    return 0
}

setBasename()
{
    local curdir=$(pwd)
    
    BASENAME=$(basename $curdir)

    return 0
}

createWorkspace()
{
    local target=$1
    local dryrun=$2
    local path=
    local options=
    local retval=

    if [ -e $target ]; then
        echo "Error: Target directory already exists"
        return 1
    fi

    echo "--------------------------------"
    echo "mkdir -p $target"
    if [ -z "$dryrun" ]; then
        ( mkdir -p $target )
    fi
    echo ""

    retval=$?

    if [ $retval -eq 1 ]; then
        echo "Failed to make directory '$target'"
        return 1
    fi

    path="${target}/"
    options="$OPTIONS"
    if [ -n "$dryrun" ]; then
        options="${options}${DRYRUN}"
    fi
   
    echo "--------------------------------"
    echo "$RSYNC $options --exclude=\"*project*\" ./template/ $path"

    ( $RSYNC $options --exclude="*project*" ./template/ $path )
    echo ""

    echo "--------------------------------"
    echo "mkdir -p $target/tcamake"
    if [ -z "$dryrun" ]; then
        ( mkdir -p "$target/tcamake" )
    fi
    echo ""

    echo "--------------------------------"
    echo "$RSYNC $options ./ ${target}/tcamake/"

    ( $RSYNC $options ./ "${target}/tcamake/" )
    echo ""

    return 0
}


if [ -z "$1" ]; then
    usage
    exit 1
fi

setBasename

if [ "$BASENAME" == "bin" ]; then
    pushd .. > /dev/null
    setBasename
fi

if [ "$BASENAME" != "tcamake" ]; then
    echo "Invalid location, tcamake not found"
    echo "Must run this script from within 'tcamake'"
    exit 1
fi

createWorkspace $1 $2

popd > /dev/null

exit 0
