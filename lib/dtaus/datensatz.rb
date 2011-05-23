module Dtaus
  
  # Vollständiger DTA-Datensatz mit Header (A), Body (C) und Footer (E)
  class Datensatz

    attr_reader :auftraggeber, :buchungen, :datum, :positiv
    alias :positiv? :positiv

    # Vollständigen DTA-Datensatz erstellen
    #
    # Parameter:
    # * autraggeber, das Dtaus::Konto des Auftraggebers
    # * datum, gewünschtes Datum des Datensatzes,
    #   optional, Default-Wert ist die aktuelle Zeit
    #
    def initialize(_auftraggeber, _datum = Time.now)
      raise DtausException.new("Konto expected, got #{_auftraggeber.class}") unless _auftraggeber.is_a?(Konto)
      raise DtausException.new("Date or Time expected, got #{_datum.class}") unless _datum.is_a?(Date) or _datum.is_a?(Time)

      @datum        = _datum
      @auftraggeber = _auftraggeber
      @buchungen    = []
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
      raise DtausException.new("Keine Buchungen vorhanden") unless buchungen.size > 0
      
      temp  = dataA
      temp += buchungen.inject(''){|temp, buchung| temp += buchung.to_dta}
      temp += dataE
      
      raise IncorrectSizeException.new("Datensatzlänge ist nicht durch 128 teilbar: #{temp.size}") if temp.size % 128 != 0
      
      temp
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

  private

    # Checksumme der Kontonummern
    #
    def checksum_konto
      @buchungen.inject(0) {|sum, buchung| sum += buchung.konto.nummer}
    end

    # Checksumme der Bankleitzahlen
    #
    def checksum_blz
      @buchungen.inject(0) {|sum, buchung| sum += buchung.konto.blz}
    end

    # Checksumme der Beträge
    #
    def checksum_betrag
      @buchungen.inject(0) {|sum, buchung| sum += buchung.betrag}
    end

    # Erstellt A-Segment der DTAUS-Datei
    # HEADER
    #
    # Aufbau des Segments:
    #
    # Nr. Start Länge     Beschreibung
    # 1   0     4 Zeichen   Länge des Datensatzes, immer 128 Bytes, also immer "0128"
    # 2   4     1 Zeichen   Datensatz-Typ, immer 'A'
    # 3   5     2 Zeichen   Art der Transaktionen
    #             "LB" für Lastschriften Bankseitig
    #             "LK" für Lastschriften Kundenseitig
    #             "GB" für Gutschriften Bankseitig
    #             "GK" für Gutschriften Kundenseitig
    # 4   7     8 Zeichen   Bankleitzahl des Auftraggebers
    # 5   15    8 Zeichen   CST, "00000000", nur belegt, wenn Diskettenabsender Kreditinstitut
    # 6   23    27 Zeichen  Name des Auftraggebers
    # 7   50    6 Zeichen   aktuelles Datum im Format DDMMJJ
    # 8   56    4 Zeichen   CST, "    " (Blanks)
    # 9   60    10 Zeichen  Kontonummer des Auftraggebers
    # 10  70    10 Zeichen  Optionale Referenznummer
    # 11a 80    15 Zeichen  Reserviert, 15 Blanks
    # 11b 95    8 Zeichen   Ausführungsdatum im Format DDMMJJJJ. Nicht jünger als Erstellungsdatum (A7), jedoch höchstens 15 Kalendertage später. Sonst Blanks.
    # 11c 103   24 Zeichen  Reserviert, 24 Blanks
    # 12  127   1 Zeichen   Währungskennzeichen
    #             " " = DM
    #             "1" = Euro
    #
    # Insgesamt 128 Zeichen
    #
    def dataA
      dta = '0128'                                #  4 Zeichen  Länge des Datensatzes, immer 128 Bytes, also immer "0128"
      dta += 'A'                                  #  1 Zeichen  Datensatz-Typ, immer 'A'
      dta += typ                                  #  2 Zeichen  Art der Transaktionen
      dta += '%8i' % auftraggeber.blz             #  8 Zeichen  Bankleitzahl des Auftraggebers
      dta += '%08i' % 0                           #  8 Zeichen  CST, "00000000", nur belegt, wenn Diskettenabsender Kreditinstitut
      dta += '%-27.27s' % auftraggeber.name       # 27 Zeichen  Name des Auftraggebers
      dta += @datum.strftime("%d%m%y")            #  6 Zeichen  aktuelles Datum im Format DDMMJJ
      dta += ' ' * 4                              #  4 Zeichen  CST, "    " (Blanks)
      dta += '%010i' % auftraggeber.nummer        # 10 Zeichen  Kontonummer des Auftraggebers
      dta += '%010i' % 0                          # 10 Zeichen  Optionale Referenznummer
      dta += ' '  * 15                            # 15 Zeichen  Reserviert, 15 Blanks
      dta += '%8s' % @datum.strftime("%d%m%Y")    #  8 Zeichen  Optionales Ausführungsdatum im Format DDMMJJJJ. Nicht jünger als Erstellungsdatum (A7), jedoch höchstens 15 Kalendertage später. Sonst Blanks.
      dta += ' ' * 24                             # 24 Zeichen  Reserviert, 24 Blanks
      dta += '1'                                  #  1 Zeichen  Währungskennzeichen ('1' = Euro)
      
      raise IncorrectSizeException.new("A-Segment: #{dta.size} Zeichen, 128 erwartet.") if dta.size != 128
      
      dta
    end

    # Erstellt E-Segment (Prüfsummen) der DTAUS-Datei
    # FOOTER
    #
    # Aufbau des Segments:
    #
    # Nr. Start Länge   Beschreibung
    # 1   0   4 Zeichen   Länge des Datensatzes, immer 128 Bytes, also immer "0128"
    # 2   4   1 Zeichen   Datensatz-Typ, immer 'E'
    # 3   5   5 Zeichen   5 Blanks
    # 4   10  7 Zeichen   Anzahl der Datensätze vom Typ C
    # 5   17  13 Zeichen  Kontrollsumme Beträge
    # 6   30  17 Zeichen  Kontrollsumme Kontonummern
    # 7   47  17 Zeichen  Kontrollsumme Bankleitzahlen
    # 8   64  13 Zeichen  Kontrollsumme Euro, nur belegt, wenn Euro als Währung angegeben wurde (A12, C17a)
    # 9   77  51 Zeichen  51 Blanks
    #
    # Insgesamt 128 Zeichen
    #
    def dataE
      dta  = '0128'                       #  4 Zeichen  Länge des Datensatzes, immer 128 Bytes, also immer "0128"
      dta += 'E'                          #  1 Zeichen  Datensatz-Typ, immer 'E'
      dta += ' ' * 5                      #  5 Zeichen  5 Blanks
      dta += '%07i' % @buchungen.size     #  7 Zeichen  Anzahl der Datensätze vom Typ C
      dta += '0' * 13                     # 13 Zeichen  Kontrollsumme Beträge in DM
      dta += '%017i' % checksum_konto     # 17 Zeichen  Kontrollsumme Kontonummern
      dta += '%017i' % checksum_blz       # 17 Zeichen  Kontrollsumme Bankleitzahlen
      dta += '%013i' % checksum_betrag    # 13 Zeichen  Kontrollsumme Beträge in Euro
      dta += ' '  * 51                    # 51 Zeichen  51 Blanks
      
      raise IncorrectSize.new("E-Segment: #{dta.size}, 128 erwartet") if dta.size != 128
      
      dta
    end

  end
  
end