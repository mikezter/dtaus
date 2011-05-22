# encoding: utf-8

module Dtaus

  # Kontodaten verwalten mit Name des Inhabers und Bank, Bankleitzahl und Kontonummer.
  #
  # Kundenkonto:
  #  konto = Konto.new(kontonummer, bankleitzahl, inhaber, bankname, false, kundennummer)
  # oder einfach
  #  konto = Konto.new(kontonummer, bankleitzahl, inhaber, bankname)
  #
  # Auftraggeberkonto:
  #  konto = Konto.new(kontonummer, bankleitzahl, inhaber, bankname, true)
  #
  class Konto
    attr_reader  :blz, :bank, :name, :kunnr, :auftraggeber, :nummer

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

    def erweiterungen
      Erweiterung.from_string(auftraggeber ? :auftraggeber : :kunde, name)
    end

  end
end
