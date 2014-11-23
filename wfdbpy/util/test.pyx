"""
Utility methods for testing
"""
cimport wfdbpy.wfdb as wfdb
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
import numpy as np
from wfdbpy.util.error import *

__cython_init = True

def wfdbquit_before(test):
    """Decorator that calls wfdbquit() before running the test
    """
    def wrapper(*args, **kwargs):
        wfdb.wfdbquit()
        return test(*args, **kwargs)
    return wrapper


def call_wfdbquit():
    """Calls wfdbquit()
    """
    wfdb.wfdbquit()


def read_100s(int num_samples, bint by_frame=False):
    """Read some signals from the 100s record of physionet
    """
    cdef wfdb.WFDB_Sample* v
    cdef wfdb.WFDB_Siginfo* s
    record = bytes("100s", "ascii")
    cdef int nsig = wfdb.isigopen(record, NULL, 0)
    if nsig < 1:
        raise WFDB_CError("couldn't read file", nsig)
    #allocate memory
    s = <wfdb.WFDB_Siginfo *>PyMem_Malloc(nsig * sizeof(wfdb.WFDB_Siginfo))
    if (wfdb.isigopen(record, s, nsig) != nsig):
        raise WFDB_CError("didn't get expected # of signals", nsig)
    v = <wfdb.WFDB_Sample *>PyMem_Malloc(nsig * sizeof(wfdb.WFDB_Sample))
    #iterate and append
    samples = []
    for i in range(num_samples):
        if wfdb.getvec(v) < 0:
            raise WFDB_Error("exited early from loop")
        subsamples = []
        for j in range(nsig):
            subsamples.append(v[j])
        samples.append(tuple(subsamples))
    #free
    PyMem_Free(s)
    PyMem_Free(v)
    return samples
