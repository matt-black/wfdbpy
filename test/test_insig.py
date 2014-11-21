"""
Tests for the functionality of reading input signals
"""
import pytest
from wfdbpy.signal import SignalReader, InputSignal
from wfdbpy.util.test import *

record = bytes('100s', encoding='ascii')
num_samples = 10
known_good10samp = read_100s(10)

@pytest.fixture
def wfdbquitter():
    call_wfdbquit()

def test_inputsignal_getvec(wfdbquitter):
    """Test that the generator for input signal works for getvec
    """
    sig = InputSignal(record)
    for i in range(num_samples):
        comp = next(sig)
        assert comp == known_good10samp[i]


def test_signalreader_getvec(wfdbquitter):
    """Test that the signal reader works just like the inputsignal
    (copies test_inputsignal_getvec but for SignalReader)
    """
    #NOTE: should probably reset the time to 0, but quitter resets this
    sr = SignalReader(record)
    for i in range(num_samples):
        comp = next(sr)
        assert comp == known_good10samp[i]


def test_signalreader_gv_cm(wfdbquitter):
    """Test that the SignalReader works as a context manager
    """
    with SignalReader(record) as sr:
        for i in range(num_samples):
            comp = next(sr)
            assert comp == known_good10samp[i]
