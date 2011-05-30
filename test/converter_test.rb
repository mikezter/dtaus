# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ConverterTest < Test::Unit::TestCase

  def test_convert_text
    assert_equal "ABC", DTAUS::Converter.convert_text("Abc")
    assert_equal "AEOEUESS", DTAUS::Converter.convert_text("äöüß")
    assert_equal "AEOEUE", DTAUS::Converter.convert_text("ÄÖÜ")
  end

  def test_convert_text_nicht_druckbare_zeichen
    # nicht druckbare zeichen sollten entfernt werden
    assert_equal "SREN HLBERG", DTAUS::Converter.convert_text("Søren Åhlberg")
    assert_equal "DEIN 50%IGER ANTEIL AN DER MIO  -", DTAUS::Converter.convert_text("Dein 50%iger Anteil an der ½Mio ¥ ;-)")
    assert_equal "MIETE/NEBENKOSTEN", DTAUS::Converter.convert_text("Miete/Nebenkosten")
  end

  def test_convert_number
    assert_equal 123, DTAUS::Converter.convert_number("123")
    assert_equal 123, DTAUS::Converter.convert_number("0123")
    assert_equal 234567, DTAUS::Converter.convert_number("23.45.67")
    assert_equal 112345, DTAUS::Converter.convert_number("Hauptstraße 1a; 12345 Musterstadt")
  end

  def test_convert_number_incorrect_class
    exception = assert_raise( DTAUS::DTAUSException ) do
      DTAUS::Converter.convert_number(123.45)
    end
    assert_equal "Cannot convert Float to Integer", exception.message

    exception = assert_raise( DTAUS::DTAUSException ) do
      DTAUS::Converter.convert_number({:number => 123})
    end
    assert_equal "Cannot convert Hash to Integer", exception.message
  end

end
