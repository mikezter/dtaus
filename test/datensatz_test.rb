require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class DatensatzTest < Test::Unit::TestCase

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
    @buchung = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    @buchung_negativ = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => -100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
  end

  def test_initialize
    dta = Dtaus::Datensatz.new(@konto_auftraggeber)
    assert dta, "Datensatz kann ohne Datum angelegt werden"
    assert_equal @konto_auftraggeber, dta.auftraggeber_konto
    assert_in_delta Time.now, dta.ausfuehrungsdatum, 0.01

    time = DateTime.parse('2011-05-23T14:59:55+02:00')
    dta = Dtaus::Datensatz.new(@konto_auftraggeber, time)
    assert dta, "Datensatz kann mit Datum und Zeit angelegt werden"
    assert_equal @konto_auftraggeber, dta.auftraggeber_konto
    assert_equal time, dta.ausfuehrungsdatum

    date = Date.parse('2011-05-23')
    dta = Dtaus::Datensatz.new(@konto_auftraggeber, date)
    assert dta, "Datensatz kann mit Datum angelegt werden"
    assert_equal @konto_auftraggeber, dta.auftraggeber_konto
    assert_equal date, dta.ausfuehrungsdatum
  end

  def test_initialize_incorrect_auftraggeber
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Datensatz.new('0123456789')
    end
    assert_equal "Konto expected, got String", exception.message
  end

  def test_initialize_incorrect_datetime
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Datensatz.new(@konto_auftraggeber, 2011)
    end
    assert_equal "Date or Time expected, got Fixnum", exception.message
  end

  def test_add
    dta = Dtaus::Datensatz.new(@konto_auftraggeber)
    assert_equal [], dta.buchungen
    assert_equal nil, dta.positiv?

    dta.add(@buchung)
    assert_equal [@buchung], dta.buchungen
    assert_equal true, dta.positiv?

    dta.add(@buchung)
    assert_equal [@buchung, @buchung], dta.buchungen
    assert_equal true, dta.positiv?
  end
  
  def test_add_incorrect_buchung
    dta = Dtaus::Datensatz.new(@konto_auftraggeber)

    exception = assert_raise( Dtaus::DtausException ) do
      dta.add("buchung")
    end
    assert_equal "Buchung expected, got String", exception.message
  end

  def test_add_mit_vorzeichenwechsel
    dta = Dtaus::Datensatz.new(@konto_auftraggeber)
    assert_equal nil, dta.positiv?

    dta.add(@buchung)
    assert_equal true, dta.positiv?

    exception = assert_raise( Dtaus::DtausException ) do
      dta.add(@buchung_negativ)
    end
    assert_equal "Nicht erlaubter Vorzeichenwechsel! Buchung muss wie die vorherigen Buchungen positiv sein!", exception.message
  end

  def test_to_dta
    dta = Dtaus::Datensatz.new(@konto_auftraggeber)
    
    exception = assert_raise( Dtaus::DtausException ) do
      dta.to_dta
    end
    assert_equal "Keine Buchungen vorhanden", exception.message
    
    dta.add(@buchung)
    assert_equal "0128ALK1234567800000000AUFTRAGGEBER               "+
                 "230511    98765432100000000000               23052"+
                 "011                        10303C00000000123456781"+
                 "234567890000000000000005000 0000000000012345678987"+
                 "654321000000010000   KUNDE                        "+
                 "      AUFTRAGGEBER               VIELEN DANK FUER "+
                 "IHREN EINK1  0401KUNDE                      03AUFT"+
                 "RAGGEBER                          02VIELEN DANK FU"+
                 "ER IHREN EINK02AUF!                               "+
                 "                                                  "+
                 "            0128E     0000001000000000000000000001"+
                 "234567890000000000123456780000000010000           "+
                 "                                        ", dta.to_dta
  end
  
end