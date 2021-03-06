"""
Custom errors/exceptions that may be raised by this library
"""

class WFDB_Error(Exception):
    """Base exception class for all errors generated by WFDB functions
    """
    pass

class WFDB_CError(WFDB_Error):
    """Exceptions that are raised as a result of catching error return codes
    from the C WFDB Library

    Notes:
      The return code of this error should match that of the error code
      returned by the underlying C function
    """

    def __init__(self, message, return_code=None):
        super(WFDB_CError, self).__init__(message)  #call base class
        self.return_code = return_code
