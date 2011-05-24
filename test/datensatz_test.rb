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
    dta = Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber)
    assert dta, "Datensatz kann ohne Datum angelegt werden"
    assert_equal @konto_auftraggeber, dta.auftraggeber_konto
    assert_in_delta Time.now, dta.ausfuehrungsdatum, 0.01
    assert_equal :lastschrift, dta.transaktionstyp

    time = DateTime.parse('2011-05-23T14:59:55+02:00')
    dta = Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber, time)
    assert dta, "Datensatz kann mit Datum und Zeit angelegt werden"
    assert_equal @konto_auftraggeber, dta.auftraggeber_konto
    assert_equal time, dta.ausfuehrungsdatum
    assert_equal :lastschrift, dta.transaktionstyp

    date = Date.parse('2011-05-23')
    dta = Dtaus::Datensatz.new(:gutschrift, @konto_auftraggeber, date)
    assert dta, "Datensatz kann mit Datum angelegt werden"
    assert_equal @konto_auftraggeber, dta.auftraggeber_konto
    assert_equal date, dta.ausfuehrungsdatum
    assert_equal :gutschrift, dta.transaktionstyp
  end

  def test_initialize_incorrect_transaktionstyp
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Datensatz.new(:xxx, @konto_auftraggeber)
    end
    assert_equal "Transaktionstyp has to be one of [:lastschrift, :gutschrift]", exception.message
  end

  def test_initialize_incorrect_auftraggeber
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Datensatz.new(:lastschrift, '0123456789')
    end
    assert_equal "Konto expected, got String", exception.message
  end

  def test_initialize_incorrect_datetime
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber, 2011)
    end
    assert_equal "Date or Time expected, got Fixnum", exception.message
  end

  def test_add
    dta = Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber)
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
    dta = Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber)

    exception = assert_raise( Dtaus::DtausException ) do
      dta.add("buchung")
    end
    assert_equal "Buchung expected, got String", exception.message
  end

  def test_add_mit_vorzeichenwechsel
    dta = Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber)
    assert_equal nil, dta.positiv?

    dta.add(@buchung)
    assert_equal true, dta.positiv?

    exception = assert_raise( Dtaus::DtausException ) do
      dta.add(@buchung_negativ)
    end
    assert_equal "Nicht erlaubter Vorzeichenwechsel! Buchung muss wie die vorherigen Buchungen positiv sein!", exception.message
  end

  def test_to_dta
    dta = Dtaus::Datensatz.new(:lastschrift, @konto_auftraggeber, Date.parse('2011-05-23'))
    
    exception = assert_raise( Dtaus::DtausException ) do
      dta.to_dta
    end
    assert_equal "Keine Buchungen vorhanden", exception.message
    
    dta.add(@buchung)
    assert_equal \
      "0128ALK1234567800000000AUFTRAGGEBER               230511    9876543210000"+
      "0000000               23052011                        10216C0000000012345"+
      "6781234567890000000000000005000 0000000000012345678987654321000000010000 "+
      "  KUNDE                              AUFTRAGGEBER               VIELEN DA"+
      "NK FUER IHREN EINK1  0102AUF!                                            "+
      "                   0128E     00000010000000000000000000012345678900000000"+
      "00123456780000000010000                                                   ", dta.to_dta

    dta = Dtaus::Datensatz.new(:gutschrift, @konto_auftraggeber, Date.parse('2011-05-23'))
    buchung = Dtaus::Buchung.new(
      :auftraggeber_konto => @konto_auftraggeber,
      :kunden_konto => @konto,
      :betrag => 100.0,
      :transaktionstyp => :gutschrift,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    dta.add(buchung)
    assert_equal \
      "0128AGK1234567800000000AUFTRAGGEBER               230511    9876543210000"+
      "0000000               23052011                        10216C0000000012345"+
      "6781234567890000000000000051000 0000000000012345678987654321000000010000 "+
      "  KUNDE                              AUFTRAGGEBER               VIELEN DA"+
      "NK FUER IHREN EINK1  0102AUF!                                            "+
      "                   0128E     00000010000000000000000000012345678900000000"+
      "00123456780000000010000                                                   ", dta.to_dta
  end
  
  def test_fuehrende_nullen
    konto_s = Dtaus::Konto.new(
      :kontonummer => "0034567890", 
      :blz => 12345678, 
      :kontoinhaber => 'Kunde', 
      :bankname =>'Bank Name',
      :kundennummer => "0099887766"
    )
    konto_auftraggeber_s = Dtaus::Konto.new(
      :kontonummer => "0076543210", 
      :blz => 12345678, 
      :kontoinhaber => 'Auftraggeber', 
      :bankname =>'Bank Name', 
      :is_auftraggeber => true
    )
    buchung_s = Dtaus::Buchung.new(
      :auftraggeber_konto => konto_auftraggeber_s,
      :kunden_konto => konto_s,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    
    dta_s = Dtaus::Datensatz.new(:lastschrift, konto_auftraggeber_s)
    dta_s.add(buchung_s)
    
    # kontonummern und kundennummern ohne führende nullen (integer)
    konto_i = Dtaus::Konto.new(
      :kontonummer => 34567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Kunde', 
      :bankname =>'Bank Name',
      :kundennummer => 99887766
    )
    konto_auftraggeber_i = Dtaus::Konto.new(
      :kontonummer => 76543210, 
      :blz => 12345678, 
      :kontoinhaber => 'Auftraggeber', 
      :bankname =>'Bank Name', 
      :is_auftraggeber => true
    )
    buchung_i = Dtaus::Buchung.new(
      :auftraggeber_konto => konto_auftraggeber_i,
      :kunden_konto => konto_i,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    
    dta_i = Dtaus::Datensatz.new(:lastschrift, konto_auftraggeber_i)
    dta_i.add(buchung_i)
    
    assert_equal dta_s.to_dta, dta_i.to_dta
  end
  
end