require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ErweiterungTest < Test::Unit::TestCase

  def test_initialize
    konto = Dtaus::Konto.new(1234567890, 12345678, 'Inhaber', 'Bank Name')
    assert konto, 'Konto kann mit Integer erstellt werden'
    assert_equal 1234567890, konto.nummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.name
    assert_equal 'BANK NAME', konto.bank
    assert_equal false, konto.auftraggeber?

    konto = Dtaus::Konto.new('1234567890', '12345678', 'Inhaber', 'Bank Name')
    assert konto, 'Konto kann mit Strings erstellt werden'
    assert_equal 1234567890, konto.nummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.name
    assert_equal 'BANK NAME', konto.bank
    assert_equal false, konto.auftraggeber?

    konto = Dtaus::Konto.new(1234567890, 12345678, 'Inhaber', 'Bank Name', true)
    assert_equal 1234567890, konto.nummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.name
    assert_equal 'BANK NAME', konto.bank
    assert_equal true, konto.auftraggeber?

    konto = Dtaus::Konto.new(1234567890, 12345678, 'Inhaber', 'Bank Name', false, 12345)
    assert_equal 1234567890, konto.nummer
    assert_equal 12345678, konto.blz
    assert_equal 'INHABER', konto.name
    assert_equal 'BANK NAME', konto.bank
    assert_equal false, konto.auftraggeber?
    assert_equal 12345, konto.kunnr
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
    erweiterungen = Dtaus::Erweiterung.from_string(:kunde, 'sehr langer text sehr langer text sehr langer text')
    assert_equal 2, erweiterungen.size
    assert_equal 'SEHR LANGER TEXT SEHR LANGE', erweiterungen[0].text
    assert_equal 'R TEXT SEHR LANGER TEXT    ', erweiterungen[1].text

    erweiterungen = Dtaus::Erweiterung.from_string(:kunde, 'kurzer text')
    assert_equal 1, erweiterungen.size
    assert_equal 'KURZER TEXT                ', erweiterungen[0].text

    erweiterungen = Dtaus::Erweiterung.from_string(:kunde, 'längerer text mit ümläuten. ßÄÖÜ und trotzdem wird korrekt getrennt')
    assert_equal 3, erweiterungen.size
    assert_equal 'LAENGERER TEXT MIT UEMLAEUT', erweiterungen[0].text
    assert_equal 'EN. SSAEOEUE UND TROTZDEM W', erweiterungen[1].text
    assert_equal 'IRD KORREKT GETRENNT       ', erweiterungen[2].text
  end

end