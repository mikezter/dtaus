require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuchungTest < Test::Unit::TestCase

  def setup
    @konto = Dtaus::Konto.new(
      :kontonummer => 1234567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Kunde', 
      :bankname =>'Bank Name'
    )
    @konto_auftraggeber = Dtaus::Konto.new(
      :kontonummer => 9876543210, 
      :blz => 12345678, 
      :kontoinhaber => 'Auftraggeber', 
      :bankname =>'Bank Name', 
      :is_auftraggeber => true
    )
  end
        
  def test_initialize
    buchung = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert buchung, "Buchung kann mit zwei Konten angelegt werden"
    assert_equal @konto, buchung.kunden_konto
    assert_equal @konto_auftraggeber, buchung.auftraggeber_konto
    assert_equal 10000, buchung.betrag
    assert_equal true, buchung.positiv?
    assert_equal "VIELEN DANK FUER IHREN EINKAUF!", buchung.verwendungszweck
    assert_equal 2, buchung.verwendungszweck_erweiterungen.size
    assert_equal 4, buchung.erweiterungen.size

    buchung = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => -100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert buchung, "Buchung kann mit negativem Betrag angelegt werden"
    assert_equal @konto, buchung.kunden_konto
    assert_equal @konto_auftraggeber, buchung.auftraggeber_konto
    assert_equal 10000, buchung.betrag
    assert_equal false, buchung.positiv?
    assert_equal "VIELEN DANK FUER IHREN EINKAUF!", buchung.verwendungszweck
  end
  
  def test_initialize_missing_parameters
    exception = assert_raise( ArgumentError ) do
      Dtaus::Buchung.new(
        #:auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => @konto,
        :betrag => 100.0
      )
    end
    assert_equal "Missing params[:auftraggeber_konto] for new Buchung.", exception.message

    exception = assert_raise( ArgumentError ) do
      Dtaus::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        #:kunden_konto => @konto,
        :betrag => 100.0
      )
    end
    assert_equal "Missing params[:kunden_konto] for new Buchung.", exception.message

    exception = assert_raise( ArgumentError ) do
      Dtaus::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => @konto
        #:betrag => 100.0
      )
    end
    assert_equal "Missing params[:betrag] for new Buchung.", exception.message

  end
  
  def test_initialize_incorrect_konto
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(
        :auftraggeber_konto => 123456789,
        :kunden_konto => @konto,
        :betrag => 100.0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Konto expected for Parameter 'auftraggeber_konto', got Fixnum", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => 123456789,
        :betrag => 100.0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Konto expected for Parameter 'kunden_konto', got Fixnum", exception.message
  end
  
  def test_initialize_incorrect_betrag
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => @konto,
        :betrag => 100,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Betrag is a Fixnum, expected Float", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => @konto,
        :betrag => 0.0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Betrag ist 0.0", exception.message
  end

  def test_initialize_incorrect_erweiterungen
    exception = assert_raise( Dtaus::IncorrectSizeException ) do
      konto = Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 12345678, 
        :kontoinhaber => 'seeeeeeeehr laaaaaaaanger naaaaaame'*3, 
        :bankname =>'Bank Name'
      )
      konto_auftraggeber = Dtaus::Konto.new(
        :kontonummer => 9876543210, 
        :blz => 12345678, 
        :kontoinhaber => 'noch viiiiiieeeeel läääääääängerer name'*3, 
        :bankname =>'Bank Name',
        :is_auftraggeber => true
      )

      Dtaus::Buchung.new(
        :auftraggeber_konto => konto_auftraggeber,
        :kunden_konto => konto,
        :betrag => 100.0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!" * 5
      )
    end
    assert_equal "Zuviele Erweiterungen: 16, maximal 15. Verwendungszweck zu lang?", exception.message
  end
  
  def test_size
    buchung = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    
    assert_equal 187 + 4 * 29, buchung.size
  end

  def test_to_dta
    assert_equal true, @konto_auftraggeber.is_auftraggeber?
    
    buchung = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    
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