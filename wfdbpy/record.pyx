"""
Cython implementation of a class representing a WFDB Record
"""
cimport wfdbpy.wfdb as wfdb
from wfdbpy.util.error import *
from cython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef public class Record:
    """Provides access to MIT-BIH database records

    Args:
      record (char*): path to the record file

    Attributes:
    """

    def __cinit__(self, char* record):
        """Opens the specified record, initializing the classs

        Args:
          record (char*): path to the record to open
        """
        #initialize the underlying signal

    property signal:
        """The input signal(s) for this record
        """
        def __get__(self):
            return self._signal

    property annotator:
        """The annotator for the signals in this record
        """
        def __get__(self):
            return self._atr
        def __set__(self, char* value):
            """Sets the input annotator for the signal
            """
            raise NotImplementedError()
