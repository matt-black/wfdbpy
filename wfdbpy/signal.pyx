"""
Signal I/O utilities and classes for the WFDB library
"""
cimport wfdbpy.wfdb as wfdb
from wfdbpy.util.error import *

import numpy as np
cimport numpy as np

from cpython.mem cimport PyMem_Free, PyMem_Malloc, PyMem_Realloc
from cpython.int cimport PyInt_FromLong
from cpython.tuple cimport PyTuple_New, PyTuple_SetItem
from python_ref cimport Py_INCREF
__cython_init = True  # see: http://stackoverflow.com/questions/8024805/cython-compiled-c-extension-importerror-dynamic-module-does-not-define-init-fu

#typedef for read functions (getvec, getframe)
ctypedef int (*read_func)(wfdb.WFDB_Sample *vector)


cdef class InputSignal:
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
    cdef wfdb.WFDB_Siginfo* siginfo_array  # info on each signal

    def __cinit__(self, char* record):
        self.record = record
        #figure out number of signals
        cdef int nsig = wfdb.isigopen(self.record, NULL, 0)
        if nsig < 1:
            raise WFDB_CError("Unable to open signal file", nsig)
        #initialize memory for structs
        self.num_sig = self.__init_memory(nsig)

    cdef int __init_memory(self, int nsig):
        """Initializes the memory for the underlying C structs

        Notes:
          Memory is initialized based on the assumption that the signal will be
          read using `getvec`. To use `getframe`, reallocate memory by calling
          `realloc_samples`

        Args:
          nsig (int): the number of signals in the record file

        Returns:
          the number of signals in the record group

        Raises:
          MemoryError: if memory for the structs can't be malloc'd
          WFDB_CError: if the record file cannot be open
        """
        #initialize memory for sample array
        self.sample_array = <wfdb.WFDB_Sample*>PyMem_Malloc(
            nsig * sizeof(wfdb.WFDB_Sample))
        if not self.sample_array:
            raise MemoryError("insufficient memory for sample array")
        #initialize memory for siginfo array
        self.siginfo_array = <wfdb.WFDB_Siginfo*>PyMem_Malloc(
            nsig * sizeof(wfdb.WFDB_Siginfo))
        if not self.siginfo_array:
            raise MemoryError("insufficient memory for signal info array")

        #open input signal file, verify nsig
        if wfdb.isigopen(self.record, self.siginfo_array, nsig) != nsig:
            raise WFDB_CError("Number of signals did not match expected")
        return nsig

    cdef int realloc_samples(self, bint frame_mode):
        """Reallocates the memory for the WFDB_Sample array based on the
        value of `frame_mode`

        Args:
          frame_mode (bool): reallocate the memory for reading with `getframe`

        Returns:
          int:

        Raises:
          MemoryError: if memory couldn't be properly reallocated
        """
        raise NotImplementedError()

    def __iter__(self):
        return self

    def __next__(self):
        cdef int rv = wfdb.getvec(self.sample_array)
        if rv > 0:  # POSSIBLE BUG: might need to check rv == nsig?
            return self.samples
        elif rv == -1:  # end of data
            raise StopIteration()
        #Errors while reading the file
        elif rv == -3 or rv == -4:
            raise WFDB_CError("failure while reading signal file", rv)
        else:
            raise WFDB_Error("unexpected failure while reading signal")

    property samples:
        """The value of the signal at the current time
        """
        def __get__(self):
            return tuple(self.sample_array[i] for i in range(self.num_sig))

    def __dealloc__(self):
        PyMem_Free(self.sample_array)
        PyMem_Free(self.siginfo_array)


cdef class SignalReader:
    """Provides Pythonic, read-only, stream-like access to an input signal for
    the specified record

    Args:
      record (char*): the record to read signals for
      frame_mode (bool): if `True`, read samples by frame

    Attributes:

    """

    cdef char* record  # the record to read signals for
    cdef read_func func  # getvec or getframe
    cdef readonly InputSignal _signal
    cdef bint use_frame

    def __cinit__(self, char* record, bint frame_mode=False):
        self.record = record
        self.use_frame = frame_mode
        self._signal = InputSignal(self.record)

    def init(self):
        """Initializes the underlying signal so that the reader can start
        """
        self.jump_to_time(0)
        if getattr(self, 'mode') == 'frame':
            self._signal.reallocate_samples(True)

    def finalize(self):
        """Closes/deallocates all associated resources
        """
        pass

    def __iter__(self):
        return self._signal

    def __next__(self):
        return next(self._signal)

    def __enter__(self):
        self.init()
        return self

    def __exit__(self, type, value, tb):
        self.finalize()  # deallocate the underlying signal

    cpdef int jump_to_time(self, int time):
        """Jump the reader to the specified time value in the signal

        Args:
          time (int): the time to jump to (next call will yield values from this time)

        Returns:
          int : the return code for isigsettime
        """
        cdef int rv
        rv = wfdb.isigsettime(time)
        return rv

    def read(self, int start=0, int stop=-1):
        """Reads the values from the signal file into a NumPy array

        Args:
          start (int): time (sample #) to start reading from
          stop (int): time (sample #) to stop reading at (inclusive), if -1, will read until EOF

        Returns:
          np.ndarray: NumPy array of WFDB_Samples for the time span
        """
        raise NotImplementedError()

        #validate inputs
        if stop < start and stop > 0:
            raise ValueError("stop must be greater than start")
        #establish looping protocol
        cdef int i = 0  # loop counter
        if stop < 0:
            cond = lambda : True
        else:
            cond = lambda : start + i <= stop

        """
        while cond():  #loop
            try:
                cdef int[:] ret = self.next()
                i++;  # iterate
            except StopIteration:
                break
        """
        return

    def read_by_time(self, int[:] start, int[:] stop):
        """Reads the values from the signal file into a NumPy array

        Args:
          start (int[4]): [HH, MM, SS, SSS] time to start reading from
          stop (int[4]): [HH, MM, SS, SSS] time to stop reading from

        Returns:
          np.ndarray: NumPy array of sample values over the time span
          Returned array has shape (num_signals, num_samples)
        """
        #convert to sample numbers
        joiner = lambda x: ':'.join([str(x[i]) for i in range(3)]) + '.' + str(x[4])
        strs = map(joiner, [start, stop])
        times = [wfdb.strtim(bytes(s, 'ascii')) for s in strs]

        return self.read(times[0], times[1])  # call self.read()

    def set_sampling_frequency(self, double frequency):
        """Sets the sampling frequency to use when reading the signals

        Notes:
          should only be invoked BEFORE reading any signal values
          if this is not called before reading, the default frequency from the header file is used
        Args:
          frequency (double): the frequency, in Hz, to sample the signals at
        """
        if frequency <= 0:
            raise ValueError("frequency must be >0")
        wfdb.setifreq(frequency)  #set the frequency

    property mode:
        """The current mode for the signal reader

        Modes are 'frame' if using `getframe` or 'vector' if using `getvec`
        """
        def __get__(self):
            if self.use_frame:
                return 'frame'
            else:
                return 'vector'

    def __dealloc__(self):
        pass
