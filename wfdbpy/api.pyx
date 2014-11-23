"""
API function implementation
"""
from wfdbpy.api cimport string_t

cdef char* _chars(string):
    """Convert unicode input to a c-string that can be passed into the WFDB
    C library

    Notes:
      if an already valid char type is passed in, nothing happens
      WFDB library takes ASCII-encoded strings

    Args:
      string: the string to convert

    Returns:
      char[:]: an ASCII encoded C string
    """
    if isinstance(string, unicode):
        #encode to ASCII
        string = (<unicode>string).encode('ascii')
    return string


cdef unicode _ustring(string):
    """Converts the string input to a unicode string

    Useful for returning unicode from API functions back to Python

    Args:
      string: the string to convert

    Returns:
      unicode: the `string` parameter, converted to unicode
    """
    raise NotImplementedError()
