#!/bin/bash
#
#   A script for projects that wish to be extracted or
#   distributed individually outside of the workspace.
#
PNAME=${0##*\/}
AUTHOR="tcarland@gmail.com"

PARENT=".."
LINKLIST="tcamake"
DEPFILE="tcamake_depends"
RSYNC="rsync"
OPTIONS="-avCL --delete "
DRYRUN="--dry-run"
DODIST=0

dry=
retval=0

if [ -z "$TCAMAKE_HOME" ]; then
    if [ -n "$TCAMAKE_PROJECT" ]; then
        TCAMAKE_HOME="$TCAMAKE_PROJECT/tcamake"
    else
        TCAMAKE_HOME="../tcamake"
    fi
fi

if [ -n "$TCAMAKE_BUILD_LINKS" ]; then
    LINKLIST="$TCAMAKE_BUILD_LINKS $LINKLIST"
fi

# ----------------------

usage="
Creates a distribution directory that includes links to
any additional project paths needed.

Unrecognized commands are passed through to 'make'.

Additional project links can be defined by setting the 
variable TCAMAKE_BUILD_LINKS to the list of relative paths
from TOPDIR.

Synopsis:
  $PNAME [-hn] [command] {args} 

Options:
  [command]   :  a standard 'make' target or a build command

  -h|--help   : displays this help
  -n|--dryrun : enables dry-run test mode

  'dist' [project] : Creates a distribution copy in the provided path. 
  'link'           : Creates project build links only
  'unlink'         : Removes build links only
  'clean'          : Removes build links and runs 'make clean'
  'show'           : shows the determined project root and 
                     what links would be created. (dry run) 
"

# ----------------------

clearLinks()
{
    for lf in $LINKLIST; do
        if [ -L $lf ]; then
            ( unlink $lf )
        fi
    done

    return 0
}


makeLinks()
{
    echo "  <tcamake> generating links: $LINKLIST "

    for lf in $LINKLIST; do
        echo "  ln -s $TCAMAKE_PROJECT/$lf ."
        ( ln -s "$TCAMAKE_PROJECT/$lf" )
    done

    return 0
}


doBuild()
{
    local target=$1
    local rt=0

    echo ""
    if [ -n "$target" ]; then
        ( make $target )
    else
        ( make all )
    fi
    rt=$?
    echo ""

    return $rt
}


doDist()
{
    local target="$1"
    local options="$OPTIONS"
    local dstpath=

    if [ -z "$target" ]; then
        echo " 'dist' requires a target path"
        return 1
    fi

    if [ -n "$dry" ]; then
        echo "  Dry run enabled."
        options="${options}${DRYRUN}"
    fi

    dstpath="${target}/"

    if [ -e $dstpath ]; then
        echo "WARNING! target path of '$dstpath' already exists."
        echo "If you continue, the contents will be overwritten"
        echo "Are you sure you wish to continue? (Y/N)"
        read reply

        case "$reply" in
            "Y" | "y" | "yes" | "YES")
                ;;
            *)
                return 1
                ;;
        esac
    fi

    echo "$RSYNC $options ./ $dstpath"

    ( $RSYNC $options ./ $dstpath )

    return $?
}


# -----------------------
action=
rt=0

while [ $# -gt 0 ]; do
    case "$1" in
        'help'|-h|--help)
            echo "$usage"
            exit 0
            ;;
        -n|--dryrun)
            dry=1
            shift
            ;;
         *)
            action="$1"
            ;;
    esac
    shift
done

if [ -z "$action" ]; then
    usage
    exit 0
fi

case "$action" in
     'dist')
        DODIST=1
        ;;
     'link')
        findTopDirectory
        makeLinks
        exit 0
        ;;
     'unlink')
        findTopDirectory
        clearLinks
        exit 0
        ;;
     'show')
        findTopDirectory
        makeLinks 1
        exit 0
        ;;
    *)
        ;;
esac

echo ""
echo "  $PNAME running in '$PWD'"

findTopDirectory
rt=$?

if [ $rt -ne 0 ]; then
    echo "$PNAME Failed to find the 'tcamake' workspace root directory"
    exit 1
fi

clearLinks
makeLinks

if [ $DODIST -eq 0 ]; then
    doBuild $1
else
    doDist $2
fi

clearLinks

exit 0
