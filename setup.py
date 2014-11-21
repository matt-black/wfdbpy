import os, shutil, sys
import numpy
from os import path

from setuptools import setup, Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize

NAME = "wfdbpy"
VERSION = "0.1"
DESCR = "A Cython wrapper for the Physionet WFDB library"
REQUIRES = ['numpy', 'cython']

AUTHOR = "Matt Black"
EMAIL = "matt.black7@gmail.com"
URL = "http://matt-black.github.io"

LICENSE = "GPLv3"

SRC_DIR = "wfdbpy"
SRC_FILES = ["convert.pyx"]
PACKAGES = [SRC_DIR]

#find WFDB_HOME
WFDB_HOME = os.getenv('WFDB_HOME')
if WFDB_HOME is None:  #did not find it
    WFDB_HOME = '/usr/local'

INCLUDE_DIRS = [os.path.join(WFDB_HOME, "include", "wfdb"),
                numpy.get_include()]

#define the extensions
ext_conv = Extension("wfdbpy.convert",
                     sources=[os.path.join(SRC_DIR, "convert.pyx")],
                     include_dirs=INCLUDE_DIRS,
                     libraries=["wfdb"],
                     language="c",
                     extra_compile_args=["-fopenmp", "-O3"],
                     extra_link_args=["-DSOME_DEFINE_OPT",
                                      "-L{}/lib64/".format(WFDB_HOME)]
                     )
ext_sig = Extension("wfdbpy.signal",
                    sources=[os.path.join(SRC_DIR, "signal.pyx")],
                    include_dirs=INCLUDE_DIRS,
                    libraries=["wfdb"],
                    language="c",
                    extra_compile_args=["-fopenmp", "-O3"],
                    extra_link_args=["-DSOME_DEFINE_OPT",
                                     "-L{}/lib64/".format(WFDB_HOME)]
                    )
ext_util = Extension("wfdbpy.util.test",
                     sources=[os.path.join(SRC_DIR, "util", "test.pyx")],
                     include_dirs=INCLUDE_DIRS,
                     libraries=["wfdb"],
                     language="c",
                     extra_compile_args=["-fopenmp", "-O3"],
                     extra_link_args=["-DSOME_DEFINE_OPT",
                                      "-L{}/lib64/".format(WFDB_HOME)])


EXTENSIONS = [ext_conv, ext_sig, ext_util]

if __name__ == "__main__":
    setup(install_requires=REQUIRES,
          packages=PACKAGES,
          zip_safe=False,

          name=NAME,
          version=VERSION,
          description=DESCR,
          license=LICENSE,

          author=AUTHOR,
          author_email=EMAIL,
          url=URL,

          cmdclass={"build_ext": build_ext},
          ext_modules=EXTENSIONS,
          )
