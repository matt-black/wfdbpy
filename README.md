# wfdbpy
A Cython wrapper for the WFDB library

## The WFDB Library

From http://physionet.org:

> This is a set of functions (subroutines) for reading and writing files in the formats used by PhysioBank databases (among others). The WFDB library is LGPLed, and can be used by programs written in ANSI/ISO C, K&R C, C++, or Fortran, running under any operating system for which an ANSI/ISO or K&R C compiler is available, including all versions of Unix, MS-DOS, MS-Windows, the Macintosh OS, and VMS.

To learn more about the WFDB Library, see http://http://physionet.org/physiotools/wfdb.shtml.

## Installing wfdbpy

From PyPi:

    pip install wfdbpy

From Source (builds extension in place, by default):

    git clone https://github.com/matt-black/wfdbpy
    cd wfdbpy
    pip install -r requirements.txt
    ./setup.sh
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib64

Using Vagrant:

    git clone https://github.com/matt-black/wfdbpy
    cd wfdbpy
    vagrant up

## Documentation

End user documentation:

#### Developers

All function/module/class documentation should use Google-style docstrings.

Docs can be built from source by executing `make html` from the /doc directory

## Testing

Tests use [py.test](pytest.org). To run the tests, execute `py.test test` from the project root.

## License

This library is licensed under GPLv3.

For more information, see `LICENSE` in the project root directory.
