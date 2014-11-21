#!/usr/bin/env bash

## SETUP SCRIPT FOR BUILDING ##
## USAGE: ./setup.sh clean/build

function show_help()
{
    echo "USAGE: ./setup.sh [-b] [-c]"
    echo "FLAGS: -b => build | -c => clean"
}

function clean()
{
    echo "Cleaning build remnants"
    #Cleans all build remnants
    rm -rf build
    rm -rf wfdbpy/*.c
    rm -rf wfdbpy/*.so
    rm -rf wfdbpy/util/*.c
    rm -rf wfdbpy/util/*.so

    #Clean pycache and *.pyc
    rm -rf test/__pycache__
    rm -rf test/*.pyc
    rm -rf wfdbpy/__pycache__
    rm -rf wfdbpy/*.pyc
}

function build()
{
    echo "Building the cython extensions"
    #Builds the extensions, inplace
    # adapted from: http://stackoverflow.com/questions/16993927/using-cython-to-link-python-to-a-shared-library

    CC="gcc" \
    CXX="g++" \
    CFLAGS="-I/usr/local/include/wfdb/ -I../../../DEPENDENCIES/python3.4/inc -I../../../DEPENDENCIES/gsl-1.15" \
    LDFLAGS="-L/usr/local/lib64/" \

    python3 setup.py build_ext --inplace
}

function pytest()
{
    py.test -s
}

while getopts "hbct" opt; do
    case "$opt" in
        h|\?)
            show_help
            exit 1
            ;;
        b) build
           ;;
        c) clean
           ;;
        t) pytest
           ;;
    esac
done

#shift $((OPTIND-1))

[ "$1" = "--" ] && shift

#EOF
