require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class KontoTest < Test::Unit::TestCase

  def test_initialize
    konto = Dtaus::Konto.new(1234567890, 12345678, 'Inhaber', 'Bank Name')
    assert konto, 'Konto kann mit Integer erstellt werden'
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal false, konto.is_auftraggeber?

    konto = Dtaus::Konto.new('1234567890', '12345678', 'Inhaber', 'Bank Name')
    assert konto, 'Konto kann mit Strings erstellt werden'
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal false, konto.is_auftraggeber?

    konto = Dtaus::Konto.new(1234567890, 12345678, 'Inhaber', 'Bank Name', true)
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal true, konto.is_auftraggeber?

    konto = Dtaus::Konto.new(1234567890, 12345678, 'Inhaber', 'Bank Name', false, 12345)
    assert_equal 1234567890, konto.kontonummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.kontoinhaber
    assert_equal 'BANK NAME', konto.bankname
    assert_equal false, konto.is_auftraggeber?
    assert_equal 12345, konto.kundennummer
  end

  def test_initialize_incorrect_kontonummer
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(12345678901, 12345678, 'Inhaber', 'Bank Name')
    end
    assert_equal "Ungültige Kontonummer: 12345678901", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(0, 12345678, 'Inhaber', 'Bank Name')
    end
    assert_equal "Ungültige Kontonummer: 0", exception.message
  end
  
  def test_initialize_incorrect_blz
    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(1234567890, 123456789, 'Inhaber', 'Bank Name')
    end
    assert_equal "Ungültige Bankleitzahl: 123456789", exception.message

    exception = assert_raise( Dtaus::DtausException ) do
      Dtaus::Konto.new(1234567890, 0, 'Inhaber', 'Bank Name')
    end
    assert_equal "Ungültige Bankleitzahl: 0", exception.message
  end
  
  def test_erweiterungen
    konto = Dtaus::Konto.new(1234567890, 12345678, 'Sehr laaaaaanger Inhaber Name GmbH', 'Bank Name', true, 12345)
    
    erw = konto.erweiterungen
    assert erw, "Erweiterungen eines Auftraggeberkontos"
    assert_equal 2, erw.size
    assert_equal "SEHR LAAAAAANGER INHABER NA", erw[0].text
    assert_equal '03', erw[0].type
    assert_equal "ME GMBH                    ", erw[1].text
    assert_equal '03', erw[1].type
    
    konto = Dtaus::Konto.new(1234567890, 12345678, 'Sehr laaaaaanger Inhaber Name', 'Bank Name')
    
    erw = konto.erweiterungen
    assert erw, "Erweiterungen eines Kundenkontos"
    assert_equal 2, erw.size
    assert_equal "SEHR LAAAAAANGER INHABER NA", erw[0].text
    assert_equal '01', erw[0].type
    assert_equal "ME                         ", erw[1].text
    assert_equal '01', erw[1].type
    
  end

end