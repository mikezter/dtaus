require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuchungTest < Test::Unit::TestCase

  def setup
    @konto = Dtaus::Konto.new(1234567890, 12345678, 'Kunde', 'Bank Name')
    @konto_auftraggeber = Dtaus::Konto.new(9876543210, 12345678, 'Auftraggeber', 'Bank Name', true)
  end
        
  def test_initialize
    buchung = Dtaus::Buchung.new(@konto_auftraggeber, @konto, 100.0, "Vielen Dank für Ihren Einkauf!")
    
    assert buchung, "Buchung kann mit zwei Konten angelegt werden"
    assert_equal @konto, buchung.kunden_konto
    assert_equal @konto_auftraggeber, buchung.auftraggeber_konto
    assert_equal 10000, buchung.betrag
    assert_equal true, buchung.positiv?
    assert_equal "VIELEN DANK FUER IHREN EINKAUF!", buchung.verwendungszweck
    assert_equal 2, buchung.verwendungszweck_erweiterungen.size
    assert_equal 4, buchung.erweiterungen.size

    buchung = Dtaus::Buchung.new(@konto_auftraggeber, @konto, -100.0, "Vielen Dank für Ihren Einkauf!")
    
    assert buchung, "Buchung kann mit negativem Betrag angelegt werden"
    assert_equal @konto, buchung.kunden_konto
    assert_equal @konto_auftraggeber, buchung.auftraggeber_konto
    assert_equal 10000, buchung.betrag
    assert_equal false, buchung.positiv?
    assert_equal "VIELEN DANK FUER IHREN EINKAUF!", buchung.verwendungszweck
  end

  def test_initialize_incorrect_konto
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(123456789, @konto, 100.0, "Vielen Dank für Ihren Einkauf!")
    end
    assert_equal "Konto expected for Parameter 'auftraggeber_konto', got Fixnum", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(@konto, 123456789, 100.0, "Vielen Dank für Ihren Einkauf!")
    end
    assert_equal "Konto expected for Parameter 'kunden_konto', got Fixnum", exception.message
  end
  
  def test_initialize_incorrect_betrag
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(@konto_auftraggeber, @konto, 100, "Vielen Dank für Ihren Einkauf!")
    end
    assert_equal "Betrag is a Fixnum, expected Float", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(@konto_auftraggeber, @konto, 0.0, "Vielen Dank für Ihren Einkauf!")
    end
    assert_equal "Betrag ist 0.0", exception.message
  end

  def test_initialize_incorrect_erweiterungen
    exception = assert_raise( Dtaus::IncorrectSizeException ) do
      konto = Dtaus::Konto.new(1234567890, 12345678, "seeeeeeeehr laaaaaaaanger naaaaaame"*3, 'Bank Name')
      konto_auftraggeber = Dtaus::Konto.new(9876543210, 12345678, "noch viiiiiieeeeel läääääääängerer name"*3, 'Bank Name', true)

      Dtaus::Buchung.new(konto_auftraggeber, konto, 100.0, "Vielen Dank für Ihren Einkauf!" * 5)
    end
    assert_equal "Zuviele Erweiterungen: 16, maximal 15. Verwendungszweck zu lang?", exception.message
  end
  
  def test_size
    buchung = Dtaus::Buchung.new(@konto_auftraggeber, @konto, 100.0, "Vielen Dank für Ihren Einkauf!")
    
    assert_equal 187 + 4 * 29, buchung.size
  end

  def test_to_dta
    buchung = Dtaus::Buchung.new(@konto_auftraggeber, @konto, 100.0, "Vielen Dank für Ihren Einkauf!")
    
    assert_equal "0303C00000000123456781234567890000000000000005000 "+
                 "0000000000012345678987654321000000010000   KUNDE  "+
                 "                            AUFTRAGGEBER          "+
                 "     VIELEN DANK FUER IHREN EINK1  0401KUNDE      "+
                 "                03AUFTRAGGEBER                    "+
                 "      02VIELEN DANK FUER IHREN EINK02AUF!         "+
                 "                                                  "+
                 "                                  ", buchung.to_dta
  end

end