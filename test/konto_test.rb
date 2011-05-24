require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class KontoTest < Test::Unit::TestCase

  def test_initialize
    konto = Dtaus::Konto.new(
      :kontonummer => 1234567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Inhaber', 
      :bankname =>'Bank Name'
    )
    assert konto, 'Konto kann mit Integer erstellt werden'
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal false, konto.is_auftraggeber?

    konto = Dtaus::Konto.new(
      :kontonummer => '1234567890', 
      :blz => '12345678', 
      :kontoinhaber => 'Inhaber', 
      :bankname =>'Bank Name'
    )
    assert konto, 'Konto kann mit Strings erstellt werden'
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal false, konto.is_auftraggeber?

    konto = Dtaus::Konto.new(
      :kontonummer => 1234567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Inhaber', 
      :bankname =>'Bank Name',
      :is_auftraggeber => true
    )
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal true, konto.is_auftraggeber?

    konto = Dtaus::Konto.new(
      :kontonummer => 1234567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Inhaber', 
      :bankname =>'Bank Name',
      :is_auftraggeber => false,
      :kundennummer => "KDNR12345678901"
    )
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal false, konto.is_auftraggeber?
    assert_equal 12345678901, konto.kundennummer
  end

  def test_initialize_missing_parameters
    exception = assert_raise( ArgumentError ) do
      Dtaus::Konto.new(
        #:kontonummer => 1234567890, 
        :blz => 12345678, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Missing params[:kontonummer] for new Konto.", exception.message

    exception = assert_raise( ArgumentError ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        #:blz => 12345678, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Missing params[:blz] for new Konto.", exception.message

    exception = assert_raise( ArgumentError ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 12345678, 
        #:kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Missing params[:kontoinhaber] for new Konto.", exception.message

    exception = assert_raise( ArgumentError ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 12345678, 
        :kontoinhaber => 'Inhaber'
        #:bankname => 'Bank Name'
      )
    end
    assert_equal "Missing params[:bankname] for new Konto.", exception.message

  end
  
  def test_initialize_incorrect_kontonummer
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(
        :kontonummer => 12345678901, 
        :blz => 12345678, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Ungültige Kontonummer: 12345678901", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(
        :kontonummer => 0, 
        :blz => 12345678, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Ungültige Kontonummer: 0", exception.message
  end
  
  def test_initialize_incorrect_blz
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 123456789, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Ungültige Bankleitzahl: 123456789", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 0, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name'
      )
    end
    assert_equal "Ungültige Bankleitzahl: 0", exception.message
  end
  
  def test_initialize_incorrect_kundennummer
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 12345678, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name',
        :kundennummer => "KDNR123456789012"
      )
    end
    assert_equal "Ungültige Kundennummer: 123456789012", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(
        :kontonummer => 1234567890, 
        :blz => 12345678, 
        :kontoinhaber => 'Inhaber', 
        :bankname => 'Bank Name',
        :kundennummer => 123456789012
      )
    end
    assert_equal "Ungültige Kundennummer: 123456789012", exception.message
  end
  
  def test_erweiterungen
    konto = Dtaus::Konto.new(
      :kontonummer => 1234567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Sehr laaaaaanger Inhaber Name kaum zu ' + 
                       'glauben wie lang der tatsächlich ist GmbH', 
      :bankname =>'Bank Name',
      :is_auftraggeber => true,
      :kundennummer => 12345
    )
    
    erw = konto.erweiterungen
    assert erw, "Erweiterungen eines Auftraggeberkontos"
    assert_equal 2, erw.size
    assert_equal "ME KAUM ZU GLAUBEN WIE LANG", erw[0].text
    assert_equal '03', erw[0].type
    assert_equal "DER TATSAECHLICH IST GMBH  ", erw[1].text
    assert_equal '03', erw[1].type
    
    konto = Dtaus::Konto.new(
      :kontonummer => 1234567890, 
      :blz => 12345678, 
      :kontoinhaber => 'Sehr laaaaaanger Inhaber Name', 
      :bankname => 'Bank Name'
    )
    
    erw = konto.erweiterungen
    assert erw, "Erweiterungen eines Kundenkontos"
    assert_equal 1, erw.size
    assert_equal "ME                         ", erw[0].text
    assert_equal '01', erw[0].type
    
  end

end