# encoding: utf-8

module DTAUS
  
  # Baut den DTAUS Datensatz aus einem DTAUS::Datensatz Objekt
  class DtaGenerator
    
    def initialize(datensatz)
      @datensatz = datensatz
    end
    
    # Header (A), Buchungen (C) und Footer (E) werden zusammengefügt
    #
    def to_dta
      raise DTAUSException.new("Keine Buchungen vorhanden") unless @datensatz.buchungen.size > 0
      
      dta = segment_a + segment_c + segment_e
      
      raise IncorrectSizeException.new("Datensatzlänge ist nicht durch 128 teilbar: #{dta.size}") if dta.size % 128 != 0
      
      dta
    end
    
    # Erstellt A-Segment (HEADER) der DTAUS-Datei
    #--
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
    #++
    # Insgesamt 128 Zeichen
    #
    def segment_a
      result = '0128'                                                     #  4 Zeichen  Länge des Datensatzes, immer 128 Bytes, also immer "0128"
      result += 'A'                                                       #  1 Zeichen  Datensatz-Typ, immer 'A'
      result += segment_a_transaktionstyp(@datensatz.transaktionstyp)     #  2 Zeichen  Art der Transaktionen
      result += '%8i' % @datensatz.auftraggeber_konto.blz                 #  8 Zeichen  Bankleitzahl des Auftraggebers
      result += '%08i' % 0                                                #  8 Zeichen  CST, "00000000", nur belegt, wenn Diskettenabsender Kreditinstitut
      result += '%-27.27s' % @datensatz.auftraggeber_konto.kontoinhaber   # 27 Zeichen  Name des Auftraggebers
      result += @datensatz.ausfuehrungsdatum.strftime("%d%m%y")           #  6 Zeichen  aktuelles Datum im Format DDMMJJ
      result += ' ' * 4                                                   #  4 Zeichen  CST, "    " (Blanks)
      result += '%010i' % @datensatz.auftraggeber_konto.kontonummer       # 10 Zeichen  Kontonummer des Auftraggebers
      result += '%010i' % 0                                               # 10 Zeichen  Optionale Referenznummer
      result += ' '  * 15                                                 # 15 Zeichen  Reserviert, 15 Blanks
      result += '%8s' % @datensatz.ausfuehrungsdatum.strftime("%d%m%Y")   #  8 Zeichen  Optionales Ausführungsdatum im Format DDMMJJJJ. Nicht jünger als Erstellungsdatum (A7), jedoch höchstens 15 Kalendertage später. Sonst Blanks.
      result += ' ' * 24                                                  # 24 Zeichen  Reserviert, 24 Blanks
      result += '1'                                                       #  1 Zeichen  Währungskennzeichen ('1' = Euro)
      
      raise IncorrectSizeException.new("A-Segment: #{result.size} Zeichen, 128 erwartet.") if result.size != 128
      
      result
    end
    
    def segment_c
      result = ''
      
      @datensatz.buchungen.each do |buchung|
        result += segment_c_buchung(buchung)
        result += segment_c_erweiterungen(buchung)
      end
      
      result
    end
    
    # Erstellt ein C-Segments für eine Buchung
    #
    def segment_c_buchung(buchung)
      # Länge des DTA-Datensatzes
      erweiterungen = buchung.erweiterungen + @datensatz.auftraggeber_konto.erweiterungen
      
      result  = '%04i' % (187 + erweiterungen.size * 29)             #  4 Zeichen  Länge des Datensatzes, 187 + x * 29 (x..Anzahl Erweiterungsteile)
      result += 'C'                                                  #  1 Zeichen  Datensatz-Typ, immer 'C'
      result += '%08i' % 0                                           #  8 Zeichen  Bankleitzahl des Auftraggebers (optional)
      result += '%08i' % buchung.kunden_konto.blz                    #  8 Zeichen  Bankleitzahl des Kunden
      result += '%010i' % buchung.kunden_konto.kontonummer           # 10 Zeichen  Kontonummer des Kunden
      result += '0%011i0' % buchung.kunden_konto.kundennummer        # 13 Zeichen  Verschiedenes 1. Zeichen: "0" 2. - 12. Zeichen: interne Kundennummer oder Nullen 13. Zeichen: "0"
      result += segment_c_transaktionstyp(buchung.transaktionstyp)   #  5 Zeichen  Art der Transaktion (7a: 2 Zeichen, 7b: 3 Zeichen)
      result += ' '                                                  #  1 Zeichen  Reserviert, " " (Blank)
      result += '0' * 11                                             # 11 Zeichen  Betrag
      result += '%08i' % @datensatz.auftraggeber_konto.blz           #  8 Zeichen  Bankleitzahl des Auftraggebers
      result += '%010i' % @datensatz.auftraggeber_konto.kontonummer  # 10 Zeichen  Kontonummer des Auftraggebers
      result += '%011i' % buchung.betrag                             # 11 Zeichen  Betrag in Euro einschließlich Nachkommastellen, nur belegt, wenn Euro als Währung angegeben wurde
      result += ' ' * 3                                              #  3 Zeichen  Reserviert, 3 Blanks
      result += buchung.kunden_konto.kontoinhaber[0..26].ljust(27)   # 27 Zeichen  Name des Kunden
      result +=  ' ' * 8                                             #  8 Zeichen  Reserviert, 8 Blanks
      
      if result.size != 128
        raise IncorrectSizeException.new("C-Segement 1: #{result.size} Zeichen, 128 erwartet (#{buchung.kunden_konto.kontoinhaber})")
      end
      
      result
    end
    
    # Erstellt den Erweiterungen-Teil des C-Segments für diese Buchung
    #
    def segment_c_erweiterungen(buchung)
      erweiterungen = buchung.erweiterungen + @datensatz.auftraggeber_konto.erweiterungen
      
      result  = @datensatz.auftraggeber_konto.kontoinhaber[0..26].ljust(27)   # 27 Zeichen  Name des Auftraggebers
      result += buchung.verwendungszweck[0..26].ljust(27)                     # 27 Zeichen  Verwendungszweck
      result += '1'                                                           # 1 Zeichen  Währungskennzeichen ('1' = Euro)
      result += '  '                                                          # 2 Zeichen   Reserviert, 2 Blanks
      result += "%02i" % erweiterungen.size                                   # 2 Zeichen   Anzahl der Erweiterungsdatensätze, "00" bis "15"
      
      result += erweiterungen[0..1].inject('') {|tmp, erweiterung| tmp += "#{erweiterung.type}#{erweiterung.text}"}
      result  = result.ljust(128)
      
      if erweiterungen.size > 2
        erweiterungen[2..-1].each_slice(4) do |slice|
          result += slice.inject('') {|tmp, erweiterung| tmp += "#{erweiterung.type}#{erweiterung.text}"}.ljust(128)
        end
      end
      
      if result.size > 256 * 3 or result.size % 128 != 0
        raise IncorrectSizeException.new("Erweiterungen: #{result.size} Zeichen") 
      end
      
      result
    end
    
    # Erstellt E-Segment (Prüfsummen) der DTAUS-Datei
    #--
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
    #++
    # Insgesamt 128 Zeichen
    #
    def segment_e
      result  = '0128'                              #  4 Zeichen  Länge des Datensatzes, immer 128 Bytes, also immer "0128"
      result += 'E'                                 #  1 Zeichen  Datensatz-Typ, immer 'E'
      result += ' ' * 5                             #  5 Zeichen  5 Blanks
      result += '%07i' % @datensatz.buchungen.size  #  7 Zeichen  Anzahl der Datensätze vom Typ C
      result += '0' * 13                            # 13 Zeichen  Kontrollsumme Beträge in DM
      result += '%017i' % checksum_konto            # 17 Zeichen  Kontrollsumme Kontonummern
      result += '%017i' % checksum_blz              # 17 Zeichen  Kontrollsumme Bankleitzahlen
      result += '%013i' % checksum_betrag           # 13 Zeichen  Kontrollsumme Beträge in Euro
      result += ' '  * 51                           # 51 Zeichen  51 Blanks
      
      raise IncorrectSize.new("E-Segment: #{result.size}, 128 erwartet") if result.size != 128
      
      result
    end
  
  private

    # Checksumme der Kontonummern
    #
    def checksum_konto
      @datensatz.buchungen.inject(0) {|sum, buchung| sum += buchung.kunden_konto.kontonummer}
    end

    # Checksumme der Bankleitzahlen
    #
    def checksum_blz
      @datensatz.buchungen.inject(0) {|sum, buchung| sum += buchung.kunden_konto.blz}
    end

    # Checksumme der Beträge
    #
    def checksum_betrag
      @datensatz.buchungen.inject(0) {|sum, buchung| sum += buchung.betrag}
    end

    def segment_a_transaktionstyp(symbol)
      case symbol
      when :lastschrift
        'LK'
      when :gutschrift
        'GK'
      else
        raise Exception.new("Unknown transaktionstyp #{symbol}.")
      end
    end
    
    def segment_c_transaktionstyp(symbol)
      case symbol
      when :lastschrift
        '05000'
      when :gutschrift
        '51000'
      else
        raise Exception.new("Unknown transaktionstyp #{symbol}.")
      end
    end
    
  end
  
end