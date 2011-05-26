require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ErweiterungTest < Test::Unit::TestCase

  def test_initialize
    erw = DTAUS::Erweiterung.new(:kunde, 'text')
    
    assert erw
    assert_equal '01', erw.type
    assert_equal 27, erw.text.size
    assert_equal 'TEXT                       ', erw.text
  end

  def test_initialize_incorrect_type
    exception = assert_raise( DTAUS::IncorrectErweiterungTypeException ) do
      erw = DTAUS::Erweiterung.new(:fail, 'text')
    end
    assert_equal "Allowed types: :kunde, :verwendungszweck, :auftraggeber", exception.message
  end
  
  def test_initialize_incorrect_size
    exception = assert_raise( DTAUS::IncorrectSizeException ) do
      erw = DTAUS::Erweiterung.new(:kunde, '1234567890123456789012345678')
    end
    assert_equal "Text size may not exceed 27 Chars", exception.message
  end
  
  def test_from_string
    erweiterungen = DTAUS::Erweiterung.from_string(:kunde, 'sehr langer text sehr langer text sehr langer text')
    assert_equal 1, erweiterungen.size
    assert_equal 'R TEXT SEHR LANGER TEXT    ', erweiterungen[0].text

    erweiterungen = DTAUS::Erweiterung.from_string(:kunde, 'kurzer text')
    assert_equal 0, erweiterungen.size

    erweiterungen = DTAUS::Erweiterung.from_string(:kunde, 'längerer text mit ümläuten. ßÄÖÜ und trotzdem wird korrekt getrennt')
    assert_equal 2, erweiterungen.size
    assert_equal 'EN. SSAEOEUE UND TROTZDEM W', erweiterungen[0].text
    assert_equal 'IRD KORREKT GETRENNT       ', erweiterungen[1].text
  end

end