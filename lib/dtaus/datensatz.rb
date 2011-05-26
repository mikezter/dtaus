# encoding: utf-8

module DTAUS
  
  # Vollständiger DTA-Datensatz mit Header (A), Body (C) und Footer (E)
  class Datensatz

    attr_reader :auftraggeber_konto, :buchungen, :ausfuehrungsdatum, :positiv, :transaktionstyp
    alias :positiv? :positiv

    # Vollständigen DTA-Datensatz erstellen
    #
    # Parameter:
    # [<tt>_transaktionstyp</tt>] Art der Transaktionen (als :Symbol)
    #                             * <tt>:lastschrift</tt> für Lastschriften Kundenseitig
    #                             * <tt>:gutschrift</tt> für Gutschriften Kundenseitig
    # [<tt>_auftraggeber_konto</tt>] das DTAUS::Konto des Auftraggebers
    # [<tt>_ausfuehrungsdatum</tt>] Ausführungsdatum des Datensatzes,
    #                               _optional_, Default-Wert ist die aktuelle Zeit
    #
    def initialize(_transaktionstyp, _auftraggeber_konto, _ausfuehrungsdatum = Time.now)
      unless [:lastschrift, :gutschrift].include?(_transaktionstyp)
        raise DTAUSException.new("Transaktionstyp has to be one of [:lastschrift, :gutschrift]") 
      end
      unless _auftraggeber_konto.is_a?(Konto)
        raise DTAUSException.new("Konto expected, got #{_auftraggeber_konto.class}") 
      end
      unless _ausfuehrungsdatum.is_a?(Date) or _ausfuehrungsdatum.is_a?(Time)
        raise DTAUSException.new("Date or Time expected, got #{_ausfuehrungsdatum.class}") 
      end

      @transaktionstyp    = _transaktionstyp
      @auftraggeber_konto = _auftraggeber_konto
      @ausfuehrungsdatum  = _ausfuehrungsdatum
      @buchungen          = []
    end

    # Eine Buchung zum Datensatz hinzufügen.
    #
    # Es wird geprüft, ob das Vorzeichen identisch mit den bisherigen Vorzeichen ist.
    #
    def add(_buchung)
      raise DTAUSException.new("Buchung expected, got #{_buchung.class}") unless _buchung.is_a?(Buchung)
      
      # Die erste Buchung bestimmt, ob alle Beträge positiv oder negativ sind.
      @positiv = _buchung.positiv? if @buchungen.empty?
      
      # Wirf Exception wenn Vorzeichen gemischt werden
      unless @positiv == _buchung.positiv?
        raise DTAUSException.new("Nicht erlaubter Vorzeichenwechsel! "+
                                 "Buchung muss wie die vorherigen Buchungen #{positiv? ? 'positiv' : 'negativ'} sein!")
      end
      
      @buchungen << _buchung
    end

    # DTA-Repräsentation dieses Datensatzes
    #
    def to_dta
      DtaGenerator.new(self).to_dta
    end
    alias :to_s :to_dta

    # Schreibt die DTAUS-Datei
    #
    # Parameter:
    # [<tt>filename</tt>] Name der zu schreibenden Datei; _optional_, Default-Wert ist <tt>DTAUS0.TXT</tt>
    #
    def to_file(filename = 'DTAUS0.TXT')
      File.open(filename, 'w') do |file|
        file << to_dta
      end
    end

  end
  
end