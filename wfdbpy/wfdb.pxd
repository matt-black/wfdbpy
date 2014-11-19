"""
Cython Wrapper for the WFDB Library

This file contains extern declarations for structs, typedefs, and functions found in:
    wfdb.h
    wfdblib.h

Author: Matthew Black
"""

from libc.stdio cimport FILE

cdef extern from "wfdb.h":

    #Simple type names
    ctypedef int WFDB_Sample  #units are adu's
    ctypedef long WFDB_Time  #units are sample intervals
    ctypedef long WFDB_Date  #units are days
    ctypedef double WFDB_Frequency  #units are Hz
    ctypedef double WFDB_Gain  #units are adu/physical unit
    ctypedef unsigned int WFDB_Group  #signal group number
    ctypedef unsigned int WFDB_Signal  #signal number
    ctypedef unsigned int WFDB_Annotator  #annotator number

    #composite type definitions
    cdef:
        struct WFDB_siginfo:
            char* fname  #filename of signal file
            char* desc  #signal description
            char* units  #physical units (mV)
            double gain  #gain (ADC units/physical unit)
            unsigned int group  #signal group number
            int fmt  #format
            int spf  #samples/frame
            int bsize  #block size
            int adcres  #ADC resolution in bits
            int adczero  #ADC output given 0 VDC input
            int baseline  #ADC output given 0 p.u. input
            int nsamp  #number of samples
            int cksum  #16-bit checksum

        struct WFDB_calinfo:
            double low  #low level of calibration pulse
            double high  #high level of calibration pulse
            double scale  #plotting scale, units/cm
            char *sigtype  #signal type
            char *units  #units
            int caltype  #calibration pulse type

        struct WFDB_anninfo:
            char *name  #annotator name
            int stat  #file type/access code

        struct WFDB_ann:
            long time  #annotation time
            char anntyp #annotation type
            signed char subtyp  #annotation subtype
            unsigned char chan  #channel number
            signed char num  #annotator number
            unsigned char *aux  #pointer to auxiliary info

        struct WFDB_seginfo:
            char recname[51]  #segment name
            long nsamp  #number samples in segment
            long samp0  #sample number of first sample

    ctypedef WFDB_siginfo WFDB_Siginfo
    ctypedef WFDB_calinfo WFDB_Calinfo
    ctypedef WFDB_anninfo WFDB_Anninfo
    ctypedef WFDB_ann WFDB_Annotation
    ctypedef WFDB_seginfo WFDB_Seginfo

#START: section defined in annot.c

    int annopen(char *record, WFDB_anninfo *aiarray, unsigned int nann)

    int getann(WFDB_Annotator n, WFDB_ann *annot)
    int ungetann(WFDB_Annotator n, WFDB_ann *annot)
    int putann(WFDB_Annotator n, WFDB_ann *annot)

    int iannsettime(long t)

    char* ecgstr(int code)
    int strecg(char *str)
    int setecgstr(int code, char *string)

    char* annstr(int code)
    int strann(char *str)
    int setannstr(int code, char *string)

    char* anndesc(int code)
    int setanndesc(int code, char *string)

    void setafreq(WFDB_Frequency f)
    WFDB_Frequency getafreq()

    void iannclose(WFDB_Annotator n)
    void oannclose(WFDB_Annotator n)

    int wfdb_isann(int code)
    int wfdb_isqrs(int code)
    int wfdb_setisqrs(int code, int newval)
    int wfdb_map1(int code)
    int wfdb_setmap1(int code, int newval)
    int wfdb_map2(int code)
    int wfdb_setmap2(int code, int newval)
    int wfdb_ammap(int code)
    int wfdb_mamap(int code, int subtype)
    int wfdb_annpos(int code)
    int wfdb_setannpos(int code, int newval)

#END: annot.c
#START: calib.c

    int calopen(char *cfname)
    int getcal(char *desc, char *units, WFDB_calinfo *cal)
    int putcal(WFDB_calinfo *cal)
    int newcal(char *cfname)
    void flushcal()

#END: calib.c
#START:signal.c

    int isigopen(char *record, WFDB_siginfo *siarray, int nsig)
    int osigopen(char *record, WFDB_siginfo *siarray,
                 unsigned int nsig)
    int osigfopen(WFDB_Siginfo *siarray, unsigned int nsig)

    int findsig(char *signame)
    int getspf()

    void setgvmode(int mode)
    int getgvmode()

    int setifreq(WFDB_Frequency freq)
    WFDB_Frequency getifreq()

    int getvec(WFDB_Sample *vector)
    int getframe(WFDB_Sample *vector)
    int putvec(WFDB_Sample *vector)

    int isigsettime(WFDB_Time t)
    int isgsettime(WFDB_Group g, WFDB_Time t)
    WFDB_Time tnextvec(WFDB_Signal s, WFDB_Time t)

    int setibsize(int size)
    int setobsize(int size)

    int newheader(char *record)
    int setheader(char *record, WFDB_siginfo *siarray, unsigned int nsig)
    int setmsheader(char *record, char *snarray[], unsigned int nsegments)

    int wfdbgetskew(WFDB_Signal s)
    int wfdbsetskew(WFDB_Signal s, int skew)
    long wfdbgetstart(WFDB_Signal s)
    void wfdbsetstart(WFDB_Signal s, long bytes)
    int wfdbputprolog(char *buf, long size, WFDB_Signal s)

    int setinfo(char *record)
    int putinfo(char *s)
    char* getinfo(char *record)

    WFDB_Frequency setsampfreq(WFDB_Frequency freq)
    int setbasetime(char *string)
    char* timstr(WFDB_Time t)
    char* mstimstr(WFDB_Time t)

    WFDB_Frequency getcfreq()
    void setcfreq(WFDB_Frequency freq)

    double getbasecount()
    void setbasecount(double counter)

    WFDB_Time strtim(char *string)
    char* datstr(WFDB_Date date)
    WFDB_Date strdat(char *string)

    int adumuv(WFDB_Signal s, WFDB_Sample a)
    WFDB_Sample muvadu(WFDB_Signal s, int v)
    double aduphys(WFDB_Signal s, WFDB_Sample a)
    WFDB_Sample physadu(WFDB_Signal s, double v)
    WFDB_Sample sample(WFDB_Signal s, WFDB_Time t)
    int sample_valid()

#END: signal.c
#START: wfdbinit.c

    int wfdbinit(char *record, WFDB_Anninfo *aiarray,
                 unsigned int nann, WFDB_Siginfo *siarray,
                 unsigned int nsig, int stat)
    void wfdbquit()
    void wfdbflush()

#END: wfdbinit.c
#START: wfdbio.c

    char* getwfdb()
    void setwfdb(char *p)
    void resetwfdb()
    void wfdbquiet()
    void wfdbverbose()
    char* wfdberror()
    char* wfdbfile(char *type, char *record)
    void wfdbmemerr(int exit_on_error)


cdef extern from "wfdblib.h":

    cdef struct netfile:
        char *url
        char *data
        int mode
        long base_addr
        long const_len
        long pos
        long err
        int fd

    cdef struct WFDB_FILE:
        FILE *fp
        netfile *netfp
        int type

    ctypedef netfile netfile
    ctypedef WFDB_FILE WFDB_FILE
