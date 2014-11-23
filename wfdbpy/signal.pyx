"""
Signal I/O utilities and classes for the WFDB library
"""
cimport wfdbpy.wfdb as wfdb
from wfdbpy.util.error import *

from cpython.mem cimport PyMem_Free, PyMem_Malloc, PyMem_Realloc

__cython_init = True  # see: http://stackoverflow.com/questions/8024805/cython-compiled-c-extension-importerror-dynamic-module-does-not-define-init-fu

#typedef for read functions (getvec, getframe)
ctypedef int (*read_func)(wfdb.WFDB_Sample *vector)


cdef class SignalInfo:
    """Provides Pythonic access to an input signal
    """

    cdef bint read_only  # allow properties to be 'set'
    cdef readonly char* record  # the record name
    cdef wfdb.WFDB_Siginfo* _siginfo  # the underlying C struct

    def __cinit__(self, char* record, int num_signals, bint read_only):
        self.record = record
        self.read_only = read_only
        #initialize memory for the WFDB_Siginfo struct
        self._siginfo = <wfdb.WFDB_Siginfo*>PyMem_Malloc(
            num_signals*sizeof(wfdb.WFDB_Siginfo))
        if not self._siginfo:
            raise MemoryError("error initializing Siginfo struct memory")
        #fill the underlying struct values
        if wfdb.isigopen(record, self._siginfo, num_signals) != num_signals:
            raise WFDB_CError("signal file did not have the expected # of signals")

    def __dealloc__(self):
        PyMem_Free(self._siginfo)

cdef class SignalStream:
    """Provides Pythonic, stream-like access to an input signal

    Provides memory-management and access to underlying WFDB_Sample and
    WFDB_Siginfo structs for the signal

    Args:
      record (char*): the record holding the input signals
      frequency (int): the frequency (in Hz) to read the signal with
    """

    cdef char* record  # the record this signal belongs to
    cdef readonly int num_sig  # the number of signals
    cdef wfdb.WFDB_Sample* sample_array  # sample values
    cdef bint standalone  # standalone signal
    cdef bint read_by_frame
    cdef wfdb.WFDB_Siginfo* _siginfo_arr  # siginfo array for initializing the signal, if standalone

    def __cinit__(self, char* record, int num_signals,
                  by_frame=False, bint standalone=False):
        cdef int sample_array_len  #length of sample array

        self.record = record
        self.num_sig = num_signals
        #need to allocate the underlying siginfo array, if standalone
        if standalone:
            self._siginfo_arr = <wfdb.WFDB_Siginfo*>PyMem_Malloc(
                num_signals * sizeof(wfdb.WFDB_Siginfo))
            if wfdb.isigopen(record, self._siginfo_arr, num_signals) != num_signals:
                raise WFDB_Error("could not initialize the standalone stream")

        #establish reading mode for the stream
        if by_frame:
            if not standalone:
                raise WFDB_Error("cannot initialize a standalone stream to read by frame -- must manually call realloc_samples")
            else:
                j = 0
                for i in range(num_signals):
                    j += self._siginfo_arr[i].spf
                sample_array_len = j * sizeof(wfdb.WFDB_Sample)
        else:
            sample_array_len = num_signals * sizeof(wfdb.WFDB_Sample)
        self.sample_array = <wfdb.WFDB_Sample*>PyMem_Malloc(sample_array_len)
        if not self.sample_array:
            raise MemoryError("error while alloc'ing memory for WFDB_Sample struct")

    cpdef int realloc_samples(self, int num_samples):
        """Reallocates the spaces in the sample_array

        Useful for when switching reading modes b/t getvec and getframe

        Args:
          num_samples (int): the number of samples to reallocate the array for

        Returns:
          int: 0 if successful, -1 if MemoryError
        """
        cdef wfdb.WFDB_Sample* temp
        temp = <wfdb.WFDB_Sample*>PyMem_Realloc(
            self.sample_array, num_samples * sizeof(wfdb.WFDB_Sample))
        if temp == NULL:
            return -1
        else:
            self.sample_array = temp
            return 0

    def __iter__(self):
        return self

    def __next__(self):
        cdef int rv = wfdb.getvec(self.sample_array)
        if rv > 0:  # POSSIBLE BUG: might need to check rv == nsig?
            return self.value
        elif rv == -1:  # end of data
            raise StopIteration()
        #Errors while reading the file
        elif rv == -3 or rv == -4:
            raise WFDB_CError("failure while reading signal file", rv)
        else:
            raise WFDB_Error("unexpected failure while reading signal")

    property value:
        """The value of the signal at the current time
        """
        def __get__(self):
            return tuple(self.sample_array[i] for i in range(self.num_sig))

    def __dealloc__(self):
        PyMem_Free(self.sample_array)
        if self.standalone:
            PyMem_Free(self._siginfo_arr)


cdef class SignalReader:
    """SignalReader class
    """

    cdef readonly SignalInfo info
    cdef readonly SignalStream stream
    cdef bint read_by_frame  # if True, use getframe... False -> getvec

    def __cinit__(self, char* record, bint by_frame=False):
        cdef int nsig = wfdb.isigopen(record, NULL, 0)
        if nsig <= 0:
            raise WFDB_CError("Error opening signal file for record")
        self.info = SignalInfo(record, nsig, read_only=True)
        self.stream = SignalStream(record, nsig)

    def __iter__(self):
        return self.stream

    def __next__(self):
        return next(self.stream)

    def __enter__(self):
        return self

    def __exit__(self):
        pass

    property mode:
        """The current mode for the signal reader

        The mode of the reader determines how the signal file is read in. Signals
        can be read using the wfdb functions `getvec` or `getframe`. By default,
        SignalReader uses `getvec`.
        """
        def __get__(self):
            if self.read_by_frame:
                return 'frame'
            else:
                return 'vec'
        def __set__(self, bint by_frame):
            self.read_by_frame = True
            #TODO: need to realloc the underlying signal
