#!/bin/bash
#
#       cfileinit.sh
#
#   A template for creating a source file with ifndef/define and 
#   namespace declarations, if applicable.
#
PNAME=${0##*\/}
AUTHOR="tcarland@gmail.com"

FILENAMES=
SOURCENAME=
EXT=
DEFNAME=
CLASS=1



version()
{
    echo "$PNAME, $AUTHOR"
    echo ""
}

usage()
{
    echo ""
    echo "Usage: $PNAME [-hCV] -n <namespace>  sourcefile"
    echo ""
    echo "    --help      | -h        : Show usage info and exit"
    echo "    --noclass   | -C        : Do not autogenerate cpp class header"
    echo "    --namespace | -n <name> : Creates namespace declaration"
    echo "    --version   | -V        : Show version info and exit"
    echo ""
    version
    return 0
}

setSourceName()
{
    local filename=$1
    local result=${filename##*/}
    
    SOURCENAME=${result%.*}
    EXT=${result##*.}

    return 0 
}


setDefineName()
{
    local namespace=$1
    local def=
    local Sr=
    local Nr=
    local Er=

    Sr=${SOURCENAME^^}
    Er=${EXT^^}
    Nr=${namespace^^}

    if [ -n "$namespace" ]; then
        def="_${Nr}"
    fi

    DEFNAME="${def}_${Sr}_${Er}_"

    return 0
}

# The template definition for header files
createHeader()
{
    local filename=$1
    local srcname=$2
    local define=$3
    local namespace=$4

    cat >$filename <<EOF
/**
  * @file ${filename}
  * @author 
  * 
 **/
#ifndef $define
#define $define

EOF
    if [ -n "$namespace" ]; then
        cat >>$filename <<EOF

namespace ${namespace} {

EOF
    fi

    if [ -n "$CLASS" ]; then
        cat >>$filename <<EOF
 
 class ${srcname} {
 
   public:
        
    ${srcname}();
    ~${srcname}();
        
};

EOF
    fi

    if [ -n "$namespace" ]; then
        cat >>$filename <<EOF

}  // namespace
EOF
    fi

    cat >>$filename <<EOF
    
#endif  // $define
EOF
    return
}


# The template definition for source files
createSource()
{
    local filename=$1
    local srcname=$2
    local define=$3
    local namespace=$4

    cat >$filename <<EOF
/**
  * @file ${filename}
  * @author 
  * 
 **/
#define $define

EOF
    if [ -n "$namespace" ]; then
        cat >>$filename <<EOF
        
namespace ${namespace} {

EOF
    fi

    if [ -n "$CLASS" ]; then
        cat >>$filename <<EOF
        
${srcname}::${srcname}() {}
${srcname}::~${srcname}() {}

EOF
    fi

    if [ -n "$namespace" ]; then
        cat >>$filename <<EOF
        
} // namespace

EOF
    fi

    cat >>$filename <<EOF

// $define
EOF
    return
}



# --------------------------
#  MAIN

fname=
namespace=

while [ $# -gt 0 ]; do
    case "$1" in
        -a|--author)
            shift
            AUTHOR=$1
            ;;
        -C|--noclass)
            CLASS=
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -n|--namespace)
            shift
            namespace=$1
            ;;
        -V|--version)
            version
            exit 0
            ;;
        *)
            FILENAMES="$FILENAMES $1"
            ;;
    esac
    shift
done


if [ -z "$FILENAMES" ]; then
    usage
    exit 0
fi

for fname in $FILENAMES; do

    if [ -e $fname ]; then
        echo "File '$fname' already exists. Overwrite? (y/n)"
        read reply

        case "$reply" in
            "y" | "Y" | "yes" | "YES")
                echo "Overwriting $fname"
                ;;
            *)
                echo "Aborting."
                exit 0
                ;;
        esac
    else
        echo "Generating source file $fname"
    fi

    setSourceName $fname
    setDefineName $namespace

    testext=${EXT%c*}

    if [ -n "$testext" ]; then
        createHeader $fname $SOURCENAME $DEFNAME $namespace
    else 
        createSource $fname $SOURCENAME $DEFNAME $namespace
    fi

done


exit 0
