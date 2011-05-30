# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuchungTest < Test::Unit::TestCase

  def setup
    @konto = DTAUS::Konto.new(
      :kontonummer => 1234567890,
      :blz => 12345678,
      :kontoinhaber => 'Kunde',
      :bankname =>'Bank Name'
    )
  end

  def test_initialize
    buchung = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => 100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert buchung, "Buchung kann mit zwei Konten angelegt werden"
    assert_equal @konto, buchung.kunden_konto
    assert_equal 10000, buchung.betrag
    assert_equal true, buchung.positiv?
    assert_equal "VIELEN DANK FUER IHREN EINKAUF", buchung.verwendungszweck
    assert_equal 1, buchung.erweiterungen.size

    buchung = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => -100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert buchung, "Buchung kann mit negativem Betrag angelegt werden"
    assert_equal @konto, buchung.kunden_konto
    assert_equal 10000, buchung.betrag
    assert_equal false, buchung.positiv?
    assert_equal "VIELEN DANK FUER IHREN EINKAUF", buchung.verwendungszweck

    konto = DTAUS::Konto.new(
      :kontonummer => 1234567890,
      :blz => 12345678,
      :kontoinhaber => 'Sehr laaaaaaanger Kundenname GmbH',
      :bankname =>'Bank Name'
    )
    buchung = DTAUS::Buchung.new(
      :kunden_konto => konto,
      :betrag => -100.0,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert buchung, "Buchung kann mit langem Kundennamen angelegt werden"
    assert_equal 2, buchung.erweiterungen.size
  end

  def test_initialize_missing_parameters
    exception = assert_raise( ArgumentError ) do
      DTAUS::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        #:kunden_konto => @konto,
        :betrag => 100.0
      )
    end
    assert_equal "Missing params[:kunden_konto] for new Buchung.", exception.message

    exception = assert_raise( ArgumentError ) do
      DTAUS::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => @konto
        #:betrag => 100.0
      )
    end
    assert_equal "Missing params[:betrag] for new Buchung.", exception.message

  end

  def test_initialize_incorrect_transaktionstyp
    exception = assert_raise( DTAUS::DTAUSException ) do
      DTAUS::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => @konto,
        :betrag => 100.0,
        :transaktionstyp => :xxx,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Transaktionstyp has to be one of [:lastschrift, :gutschrift]", exception.message
  end

  def test_initialize_incorrect_konto
    exception = assert_raise( DTAUS::DTAUSException ) do
      DTAUS::Buchung.new(
        :auftraggeber_konto => @konto_auftraggeber,
        :kunden_konto => 123456789,
        :betrag => 100.0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Konto expected for Parameter 'kunden_konto', got Fixnum", exception.message
  end

  def test_initialize_correct_betrag
    booking = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => 123,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert_equal 12300, booking.betrag

    booking = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => 123.00,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert_equal 12300, booking.betrag

    booking = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => 123.99,
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert_equal 12399, booking.betrag

    booking = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => BigDecimal("123.98"),
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert_equal 12398, booking.betrag

    booking = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => "123,85",
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert_equal 12385, booking.betrag

    booking = DTAUS::Buchung.new(
      :kunden_konto => @konto,
      :betrag => BigDecimal("0.019"),
      :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
    )
    assert_equal 001, booking.betrag

  end

  def test_initialize_incorrect_betrag
    exception = assert_raise( DTAUS::DTAUSException ) do
      DTAUS::Buchung.new(
        :kunden_konto => @konto,
        :betrag => "0.00",
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Betrag must not be 0.00 €!", exception.message

    exception = assert_raise( DTAUS::DTAUSException ) do
      DTAUS::Buchung.new(
        :kunden_konto => @konto,
        :betrag => 0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
      )
    end
    assert_equal "Betrag must not be 0.00 €!", exception.message
  end

  def test_initialize_incorrect_erweiterungen
    exception = assert_raise( DTAUS::IncorrectSizeException ) do
      konto = DTAUS::Konto.new(
        :kontonummer => 1234567890,
        :blz => 12345678,
        :kontoinhaber => 'seeeeeeeehr laaaaaaaanger naaaaaame ' * 9,
        :bankname =>'Bank Name'
      )

      DTAUS::Buchung.new(
        :kunden_konto => konto,
        :betrag => 100.0,
        :verwendungszweck => "Vielen Dank für Ihren Einkauf!" * 5
      )
    end
    assert_equal "Zuviele Erweiterungen: 16, maximal 15. Verwendungszweck zu lang?", exception.message
  end

end