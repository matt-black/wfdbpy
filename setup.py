import os, shutil, sys
from os import path

from setuptools import setup, Extension
from Cython.Distutils import build_ext

NAME = "wfdbpy"
VERSION = "0.1"
DESCR = "A Cython wrapper for the Physionet WFDB library"
REQURES = ['numpy', 'cython']

AUTHOR = "Matt Black"
EMAIL = "matt.black7@gmail.com"

LICENSE = "GPLv3"

SRC_DIR = "wfdbpy"
SRC_FILES = None
PACKAGES = [SRC_DIR]

#find WFDB_HOME
WFDB_HOME = os.getenv('WFDB_HOME')
if WFDB_HOME is None:  #did not find it
    WFDB_HOME = '/usr/local'

#clean previous build
dirs_to_remove = ["build"]
for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if name.startswith(SRC_DIR) and (not name.endswith(".pxd") or
                                         name.endswith(".pyx")):
            os.remove(os.path.join(root, name))
        for name in dirs:
            if name in dirs_to_remove:
                shutil.rmtree(name)

#define the extensions
ext_conv = Extension(SRC_DIR,
                     sources=[os.path.join(SRC_DIR, sf) for sf in SRC_FILES],
                     include_dirs=[os.path.join(WFDB_HOME, "include", "wfdb")],
                     libraries=["wfdb"],
                     language="c",
                     extra_compile_args=["-fopenmp", "-O3"],
                     extra_link_args=["-DSOME_DEFINE_OPT",
                                      "-L{}/lib64/".format(WFDB_HOME)]
                     )

EXTENSIONS = [ext_conv]

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
          ext_modules=EXTENSIONS
          )
