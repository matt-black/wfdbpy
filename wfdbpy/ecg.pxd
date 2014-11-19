"""
Cython Wrapper Library

Author: Matthew Black
"""

cdef extern from "ecgcodes.h":
    cdef int NOTQRS  #not a valid annot code
    cdef int NORMAL
    cdef int LBBB
    cdef int RBBB
    cdef int ABERR
    cdef int PVC
    cdef int FUSION
    cdef int NPC
    cdef int APC
    cdef int SVPB
    cdef int VESC
    cdef int NESC
    cdef int PACE
    cdef int UNKNOWN
    cdef int NOISE
    cdef int ARFCT
    cdef int STCH
    cdef int TCH
    cdef int SYSTOLE
    cdef int DIASTOLE
    cdef int NOTE
    cdef int MEASURE
    cdef int PWAVE
    cdef int BBB
    cdef int PACESP
    cdef int TWAVE
    cdef int RHYTHM
    cdef int UWAVE
    cdef int LEARN
    cdef int FLWAV
    cdef int VFON
    cdef int AESC
    cdef int SVESC
    cdef int LINK
    cdef int NAPC
    cdef int PFUS
    cdef int WFON
    cdef int PQ
    cdef int WFOFF
    cdef int JPT
    cdef int RONT
    cdef int ACMAX  #largest allowed value of valid annot code
