"""
Conversion utilities for the WFDB Library
"""
cimport wfdbpy.wfdb as wfdb
from datetime import datetime as dt


cdef inline bint _validate_code(int code):
    """Validates that the code is in the valid range 0 <= code <=49
    """
    if code > 49 or code < 0:
        return False
    else:
        return True


def _validate_date(char* date):
    """Validates that the date is in the correct format
    """
    try:
        dt.strptime(date.decode('ascii'), '%d/%m/%Y')
    except ValueError:
        return False
    return True


#typedef for code->mnemonic converting functions
ctypedef char* (*code_converter)(int code) 


cdef class AnnotConverter:
    """Utility class for converting between annotation codes and strings
    """

    @classmethod
    def code_to_string(self, int code, bint mnemonic=True, 
		       bint description=False, bint use_ecgcodes=False):
        """Converts `code` to a string mnemonic or description

        Args:
          code (int): the annotation code to convert
          mnemonic (bool): if `True`, return a mneomnic for the code
          description (bool): if `True`, return a description for the code
          use_ecgcodes (bool): if `True`, use the immutable ecg codes

        Returns:
          bytes: a string representation of the code

          Note that if `mnemonic` and `description` args are `True`, a tuple of
          length 2 is returned, (mnemonic, description)
        """
        if not _validate_code(code):
            raise ValueError("did not specify a valid code")

        cdef code_converter converter
        if use_ecgcodes:
            converter = wfdb.ecgstr
        else:
            converter = wfdb.annstr

        if mnemonic and description:
            return (converter(code), wfdb.anndesc(code))
        elif mnemonic and not description:
            return converter(code)
        elif not mnemonic and description:
            return wfdb.anndesc(code)
        else:
            raise ValueError("must specify a return type mnemonic/description")

    @classmethod
    def mnemonic_to_code(self, char* mnemonic, use_ecgcodes=False):
        """Converts the `mnemonic` to its corresponding annotation code

        Args:
          mnemonic (bytes): the mnemonic to convert
          use_ecgcodes (bool): if `True`, use immutable ecg codes

        Returns:
          int: the corresponding annotation code
          0 if the mnemonic doesn't have a corresponding code
        """
        if use_ecgcodes:
            return wfdb.strecg(mnemonic)
        else:
            return wfdb.strann(mnemonic)


cdef class DateTimeConverter:
    """Utility class for converting dates/times for WFDB functions
    """

    @classmethod
    def time_to_string(self, int t, bint ms_precision=True):
        """Converts the specified time into a string of form HH:MM:SS(.SSS)

        Args:
          t (WFDB_Time): the time to convert
          ms_precision (bool): use millisecond precision when converting

        Returns:
          bytes: a date string of form HH:MM:SS or HH:MM:SS.SSS if `ms_precision`
        """
        cdef char* timestring
        if ms_precision:
            timestring = wfdb.mstimstr(t)
        else:
            timestring = wfdb.timstr(t)
        return timestring.strip()  #strip off leading whitespace

    @classmethod
    def string_to_time(self, char* string):
        """Converts a string in standard time format (HH:MM:SS) to a time in
        units of sample intervals

        Args:
          string (bytes): the time-string to convert

        Returns:
          long : the time, in sample intervals
        """
        return wfdb.strtim(string)

    @classmethod
    def date_to_string(self, int date):
        """Converts the Julian date, `date`, to a string of form DD/MM/YYYY

        Args:
          date (long): the date to convert

        Returns:
          bytes: a string of form DD/MM/YYYY
        """
        return wfdb.datstr(date).strip()

    @classmethod
    def string_to_date(self, char* string):
        """Converts the string into a Julian date

        Args:
          string (bytes): the string (of form DD/MM/YYYY) to convert

        Returns:
          int: the Julian date for the string
        """
        if _validate_date(string):
            return wfdb.strdat(string)
        else:
            raise ValueError("did not pass a valid date string")


cdef class SignalUnitConverter:
    """Utility class for converting a signal's sample values between ADC and
    physical units

    Args:
      sig (WFDB_Signal): the underlying signal to use for conversions

    Note:
      This class relies on the underlying `gain` and `baseline` values for the
      signal it is instantiated with to convert between different units.
    """

    cdef wfdb.WFDB_Signal signal  #the input signal for the conversion

    def __cinit__(self, wfdb.WFDB_Signal sig):
        self.signal = sig

    def adc_to_phys(self, int a):
        """Convert the sample value `a` from ADC units to physical units

        Args:
          a (int): the sample value to convert (in adus)

        Returns:
          double: the sample value, in physical units
        """
        return wfdb.aduphys(self.signal, a)

    def phys_to_adc(self, double v):
        """Convert the value `v` from physical units to ADC units

        Args:
          v (double): the sample value to convert (in physical units)

        Returns:
          int: the sample value, in ADC units
        """
        return wfdb.physadu(self.signal, v)

    def adc_to_mv(self, int a):
        """Convert the sample value to microvolts

        Args:
          a (int): the sample value to convert (in ads)

        Returns:
          int: the potential difference `a` in microvolts
        """
        return wfdb.adumuv(self.signal, a)

    def mv_to_adu(self, int mv):
        """Convert the potential difference, `mv` from microvolts to ADC units

        Args:
          mv (int): the sample value, in microvolts

        Returns:
          int: the sample value, in ADC units
        """
        return wfdb.muvadu(self.signal, mv)
