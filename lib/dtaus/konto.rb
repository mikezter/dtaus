# encoding: utf-8

module Dtaus

  # Kontodaten mit Name des Inhabers, Bank, Bankleitzahl und Kontonummer.
  # Kann zwischen Auftraggeber und Kundenkonto unterscheiden.
  class Konto
    attr_reader  :blz, :bankname, :kontoinhaber, :kundennummer, :is_auftraggeber, :kontonummer

    alias :is_auftraggeber? :is_auftraggeber
    
    # Erstellt ein neues Konto
    #
    # Parameter:
    # * _kontonummer, die Kontonummer
    # * _blz, die Bankleitzahl
    # * _kontoinhaber, der Name der Kontoinhabers
    # * _bankname, der Name der Bank
    # * _is_auftraggeber, Boolischer Wert, ob dieses Konto ein Auftraggeberkonto ist,
    #   optional, default-Wert ist +false+
    # * _kundennummer, eine Kundennummer,
    #   optional, defautl-Wert ist <tt>0</tt>
    def initialize(_kontonummer, _blz, _kontoinhaber, _bankname, _is_auftraggeber = false, _kundennummer = 0)
      @is_auftraggeber = _is_auftraggeber

      @kontonummer  = Converter.convert_number(_kontonummer)
      @blz          = Converter.convert_number(_blz)
      @kundennummer = Converter.convert_number(_kundennummer)
      @kontoinhaber = Converter.convert_text(_kontoinhaber)
      @bankname     = Converter.convert_text(_bankname)

      raise DtausException.new("Ungültige Kontonummer: #{kontonummer}") if kontonummer == 0 or kontonummer.to_s.size > 10
      raise DtausException.new("Ungültige Bankleitzahl: #{blz}")   if blz  == 0 or blz.to_s.size > 8
    end

    # Erstellt eine Liste von Erweiterungen für den Kontoinhaber
    def erweiterungen
      Erweiterung.from_string(is_auftraggeber? ? :auftraggeber : :kunde, kontoinhaber)
    end

  end
end
