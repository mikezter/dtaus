# encoding: utf-8

module Dtaus
  
  # Vollständiger DTA-Datensatz mit Header (A), Body (C) und Footer (E)
  class Datensatz

    attr_reader :auftraggeber_konto, :buchungen, :ausfuehrungsdatum, :positiv
    alias :positiv? :positiv

    # Vollständigen DTA-Datensatz erstellen
    #
    # Parameter:
    # * _auftraggeber_konto, das Dtaus::Konto des Auftraggebers
    # * _ausfuehrungsdatum, Auführungsdatum des Datensatzes,
    #   optional, Default-Wert ist die aktuelle Zeit
    #
    def initialize(_auftraggeber_konto, _ausfuehrungsdatum = Time.now)
      unless _auftraggeber_konto.is_a?(Konto)
        raise DtausException.new("Konto expected, got #{_auftraggeber_konto.class}") 
      end
      unless _ausfuehrungsdatum.is_a?(Date) or _ausfuehrungsdatum.is_a?(Time)
        raise DtausException.new("Date or Time expected, got #{_ausfuehrungsdatum.class}") 
      end

      @ausfuehrungsdatum  = _ausfuehrungsdatum
      @auftraggeber_konto = _auftraggeber_konto
      @buchungen          = []
    end

    # Art der Transaktionen (2 Zeichen)
    #
    # Zum Beispiel:
    # * "LB" für Lastschriften Bankseitig
    # * "LK" für Lastschriften Kundenseitig
    # * "GB" für Gutschriften Bankseitig
    # * "GK" für Gutschriften Kundenseitig
    #
    def typ
     'LK'
    end

    # Eine Buchung zum Datensatz hinzufügen.
    #
    # Es wird geprüft, ob das Vorzeichen identisch mit den bisherigen Vorzeichen ist.
    #
    def add(_buchung)
      raise DtausException.new("Buchung expected, got #{_buchung.class}") unless _buchung.is_a?(Buchung)
      
      # Die erste Buchung bestimmt, ob alle Beträge positiv oder negativ sind.
      @positiv = _buchung.positiv? if @buchungen.empty?
      
      # Wirf Exception wenn Vorzeichen gemischt werden
      unless @positiv == _buchung.positiv?
        raise DtausException.new("Nicht erlaubter Vorzeichenwechsel! "+
                                 "Buchung muss wie die vorherigen Buchungen #{positiv? ? 'positiv' : 'negativ'} sein!")
      end
      
      @buchungen << _buchung
    end

    # DTA-Repräsentation dieses Datensatzes
    #
    # Header (A), Buchungen (C) und Footer (E) werden zusammengefügt
    #
    def to_dta
      DtaGenerator.new(self).to_dta
    end
    alias :to_s :to_dta

    # Schreibt die DTAUS-Datei
    #
    # Parameter:
    # * filename, Name der zu schreibenden Datei, Default-Wert ist <tt>DTAUS0.TXT</tt>
    #
    def to_file(filename = 'DTAUS0.TXT')
      File.open(filename, 'w') do |file|
        file << to_dta
      end
    end

  end
  
end