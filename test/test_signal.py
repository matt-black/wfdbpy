"""
Tests for functions/classes in signal.pyx
"""
import pytest
from wfdbpy.util.test import *
from wfdbpy.signal import *

##File-level variables
record = "100s"
num_signals = 2  # number of signals in the 100s record (known value)

class TestSignalStream:
    """Tests for the SignalStream class
    """

    def setup_method(self, method):
        call_wfdbquit()

    def test_getvec(self):
        """Reads 10 samples from the 100s record using getvec and makes sure
        it matches calling next 10 times on the stream
        """
        #get the known good samples
        known_good = read_100s(10, by_frame=False)
        call_wfdbquit()

        sig = SignalStream("100s", num_signals, by_frame=False, standalone=True)
        for i in range(10):
            assert next(sig) == known_good[i]

    def test_getframe(self):
        """Reads 10 samples from the 100s record using getframe and makes sure
        it matches calling next 10 times on the stream in 'frame mode
        """
        known_good = read_100s(10, by_frame=True)
        call_wfdbquit()

        sig = SignalStream("100s", num_signals, by_frame=True, standalone=True)
        for i in range(10):
            assert next(sig) == known_good[i]


class TestSignalInfo:
    """Tests for the SignalInfo class
    """

    info = SignalInfo("100s", num_signals, read_only=False)

    def test_read_props(self):
        """Read the properties of the SignalInfo object and make sure
        they match, or reasonably match, those of the underlying struct
        """
        pass


class TestSignalReader:
    """Tests for the SignalReader class
    """

    def setup_method(self, method):
        call_wfdbquit()

    def test_getvec(self):
        """Reads 10 samples from the 100s record using getvec and makes sure
        it matches calling next 10 times on the reader
        """
        known_good = read_100s(10, by_frame=False)
        call_wfdbquit()

        sig_reader = SignalReader(record, by_frame=False)
        for i in range(10):
            assert next(sig_reader) == known_good[i]

    def test_getframe(self):
        """Reads 10 samples from the 100s record using getframe and makes sure
        it matches calling next 10 times on the reader
        """
        known_good = read_100s(10, by_frame=True)
        call_wfdbquit()

        sig_reader = SignalReader(record, by_frame=True)
        for i in range(10):
            assert next(sig_reader) == known_good[i]

    def test_modeprop(self):
        """Calls the 'mode' property on the reader and makes sure it returns
        the right value
        """
        pass
