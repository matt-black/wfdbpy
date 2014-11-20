"""
Utility functions

Miscellaneous helper methods and classes for use within the library or when
interacting with the library
"""
import functools
from wfdbpy.util.error import WFDB_Error

def wfdb_exec(char* name, **kwargs):
    """Executes the named wfdb application

    Notes:
      Use of this function requires the WFDB applications be installed in the
      PATH of the user's machine

    Args:
      name (char*): the name of the WFDB program to run
      **kwargs: flag-value pairs of arguments to pass to the wfdb program
    """
    from subprocess import check_output
    args = [name] + [["-"+kw, kwargs[kw]] for kw in kwargs]
    return check_output([arg for pair in args
                         for part in pair])


def parse_output(parser):
    """Decorator to parse the output of the decorated function

    Args:
      parser: the function that will parse the output of the function
    """
    def wrap(func):
        def func_wrap(*args, **kwargs):
            rv = func(*args, **kwargs)  #call the function
            return parser(p)
        return func_wrap
    return wrap


def encode_returnval(encoding='utf8'):
    """Decorator that transforms the byte-string output of the decorated
    function to a string of the given encoding

    Args:
      encoding (str): the encoding to use for the return value (default 'utf8')
    """
    def encoding_decorator(func):
        @functools.wraps(func)
        def func_wrapper(*args, **kwargs):
            rv = func(*args, **kwargs)
            try:
                return rv.decode(encoding)
            except AttributeError:
                raise WFDB_Error("return value of decorated function was not a byte string")
        return func_wrapper
    return encoding_decorator
