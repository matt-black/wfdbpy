"""
API functionality and type declarations
"""
cimport cython

# string type for API functions
ctypedef fused string_t:
    cython.p_char
    bytes
    unicode

cdef char* _chars(string)
cdef unicode _ustring(string)

# time type
# will convert strs->ints using strtim
ctypedef fused time_t:
    int
    bytes
    unicode
