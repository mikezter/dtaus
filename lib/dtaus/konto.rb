# encoding: utf-8

module Dtaus

  # Kontodaten mit Name des Inhabers, Bank, Bankleitzahl und Kontonummer
  # Kann zwischen Auftraggeber und Kundenkonto unterscheiden
  class Konto
    attr_reader  :blz, :bank, :name, :kunnr, :auftraggeber, :nummer

    alias :auftraggeber? :auftraggeber
    
    # Erstellt ein neues Konto
    #
    # Parameter:
    # * _nummer, die Kontonummer
    # * _blz, die Bankleitzahl
    # * _name, der Name der Kontoinhabers
    # * _bank, der Name der Bank
    # * _auftraggeber, Boolischer Wert, ob diese Konto ein Auftraggeberkonto ist,
    #                  optional, default-Wert ist +false+
    # * _kunnr, eine Kundennummer,
    #           optional, defautl-Wert ist +0+
    def initialize(_nummer, _blz, _name, _bank, _auftraggeber = false, _kunnr = 0)
      @auftraggeber = _auftraggeber

      @nummer = Converter.convert_number(_nummer)
      @blz    = Converter.convert_number(_blz)
      @kunnr = Converter.convert_number(_kunnr)
      @name  = Converter.convert_text(_name)
      @bank  = Converter.convert_text(_bank)

      raise DtausException.new("Ungültige Kontonummer: #{nummer}") if nummer == 0 or nummer.to_s.size > 10
      raise DtausException.new("Ungültige Bankleitzahl: #{blz}")   if blz  == 0 or blz.to_s.size > 8
    end

    # Erstellt eine Liste von Erweiterungen für den Konto-Inhaber
    def erweiterungen
      Erweiterung.from_string(auftraggeber ? :auftraggeber : :kunde, name)
    end

  end
end
