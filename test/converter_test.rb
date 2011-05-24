require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ConverterTest < Test::Unit::TestCase

  def test_convert_text
    assert_equal "ABC", Dtaus::Converter.convert_text("Abc")
    assert_equal "AEOEUESS", Dtaus::Converter.convert_text("äöüß")
    assert_equal "AEOEUE", Dtaus::Converter.convert_text("ÄÖÜ")
    
    # FAILS
#    assert_equal "ÑØÇ", Dtaus::Converter.convert_text("Ñøç")
  end

  def test_convert_number
    assert_equal 123, Dtaus::Converter.convert_number("123")
    assert_equal 123, Dtaus::Converter.convert_number("0123")
    assert_equal 234567, Dtaus::Converter.convert_number("23.45.67")
    assert_equal 112345, Dtaus::Converter.convert_number("Hauptstraße 1a; 12345 Musterstadt")
  end

  def test_convert_number_incorrect_class
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Converter.convert_number(123.45)
    end
    assert_equal "Cannot convert Float to Integer", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Converter.convert_number({:number => 123})
    end
    assert_equal "Cannot convert Hash to Integer", exception.message
  end

end
