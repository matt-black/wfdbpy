"""
Tests for the functionality of reading input signals
"""
from wfdbpy.signal import SignalReader, InputSignal
from wfdbpy.util.test import *

record = bytes('100s', encoding='ascii')

def test_inputsignal_getvec():
    """Test that the generator for input signal works for getvec
    """
    num_samples = 10
    known_good = read_100s(num_samples)
    call_wfdbquit()

    sig = InputSignal(record)
    for i in range(num_samples):
        comp = next(sig)
        assert comp == known_good[i]
