#!/usr/bin/env bash
# setup.sh

CC="gcc" \
CXX="g++" \
CFLAGS="-I/usr/local/include/wfdb/ -I../../../DEPENDENCIES/python3.4/inc -I../../../DEPENDENCIES/gsl-1.15" \
LDFLAGS="-L/usr/local/lib64/" \

python3 setup.py build_ext --inplace

# adapted from: http://stackoverflow.com/questions/16993927/using-cython-to-link-python-to-a-shared-library
