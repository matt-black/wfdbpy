"""
Test suite for conversion functions
"""
import pytest
from wfdbpy.convert import *
from wfdbpy.util.test import *

val_err_fmt = "Traceback (most recent call last)\n    ...\nValueError: {}"

class TestAnnotationConversion:
    """Test the annotation converter, AnnotConverter
    """
    vals = {'ok': (3, 'R', 'Right bundle branch block beat'),
            'bad': (50, val_err_fmt.format('did not specify a valid code'),
                    val_err_fmt.format('did not specify a valid annot code')),
            'cust': (45, 'Z', 'This is a custom annot description')}

    converter = AnnotConverter()

    @classmethod
    def setup_class(cls):
        """Calls wfdbquit before executing the tests in this class
        """
        call_wfdbquit()

    def test_code_mnemonic(self):
        """Test code->mnemonic conversions
        """
        mnemonic = self.converter.code_to_string(self.vals['ok'][0])
        assert mnemonic.decode('ascii') == self.vals['ok'][1]

        with pytest.raises(ValueError):
            self.converter.code_to_string(self.vals['bad'][0])

    def test_code_desc(self):
        """Test code->desc conversions
        """
        desc = self.converter.code_to_string(self.vals['ok'][0], False, True)
        assert desc.decode('ascii') == self.vals['ok'][2]

    def test_code_tuple(self):
        """Test that specifying both returns tuple
        """
        desc_tup = self.converter.code_to_string(self.vals['ok'][0],
                                                 True, True)
        assert len(desc_tup) == 2

    def test_mnem_code(self):
        """Test that mnemonic->code conversions ok
        """
        mnem_ok = bytes(self.vals['ok'][1], encoding='ascii')
        mnem_bad = bytes(self.vals['bad'][1], encoding='ascii')

        assert self.converter.mnemonic_to_code(mnem_ok) == self.vals['ok'][0]
        assert self.converter.mnemonic_to_code(mnem_bad) == 0


class TestDateTimeConversion:
    """Test the time converter, TimeConverter
    """
    converter = DateTimeConverter()

    def setup_class(cls):
        """Calls wfdbquit before running tests for this class
        """
        call_wfdbquit()

    def test_time_to_string(self):
        """Test time->string conversions
        """
        ms_time = bytes('16:40.000', encoding='ascii')
        time = bytes('16:40', encoding='ascii')
        assert self.converter.time_to_string(1000) == ms_time
        assert self.converter.time_to_string(1000, False) == time

    def test_string_to_time(self):
        """Test string->time conversions
        """
        string = bytes('16:40', encoding='ascii')
        assert self.converter.string_to_time(string) == 1000

    def test_date_to_string(self):
        """Test date->string conversions
        """
        date = bytes('11/02/1991', encoding='ascii')
        assert self.converter.date_to_string(2448299) == date

    def test_string_to_date(self):
        """Test string->date conversion
        """
        ok_datstr = bytes('11/02/1991', encoding='ascii')
        bad_datstr = bytes('garbage//', encoding='ascii')  #should raise ValueError
        assert self.converter.string_to_date(ok_datstr) == 2448299
        with pytest.raises(ValueError):
            self.converter.string_to_date(bad_datstr)
