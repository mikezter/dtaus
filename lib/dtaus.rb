# encoding: utf-8

require 'date'
require 'enumerator'

require 'dtaus/buchung'
require 'dtaus/konto'
require 'dtaus/erweiterung'
require 'dtaus/converter'
require 'dtaus/exceptions'


#
# :title:DTAUS-Datei erstellen
#
# =DTAUS-Datei für Sammellastschrift erstellen
#
# Quick How-To:
#  auftraggeber = DTAUS::Konto.new(1234567890, 12345670, 'Muster GmbH', 'Deutsche Bank', true)
#  kunde = DTAUS::Konto.new(1234567890, 12345670, 'Max Meier-Schulze', 'Sparkasse')
#  buchung = DTAUS::Buchung.new(auftraggeber, kunde, 39.99, 'Vielen Dank für ihren Einkauf vom 01.01.2010. Rechnungsnummer 12345')
#  dta = DTAUS.new(auftraggeber)
#  dta.add(buchung)
#  dta.to_file
#
# Typ der Datei ist 'LK' (Lastschrift Kunde)
#
# Infos zu DTAUS: http://www.infodrom.org/projects/dtaus/dtaus.php3
# DTAUS online check: http://www.xpecto.de/index.php?id=148,7
#
module Dtaus
  
  class DtaGenerator

    attr_reader :auftraggeber, :buchungen, :datum, :positiv
    alias :positiv? :positiv

    def initialize(auftraggeber, datum = Time.new)
      raise DtausException.new("Konto expected, got #{auftraggeber.class}") unless auftraggeber.is_a?(Konto)
      raise DtausException.new("Date or Time expected, got #{datum.class}") unless datum.is_a?(Date) or datum.is_a?(Time)

      @datum        = datum
      @auftraggeber = auftraggeber
      @buchungen    = []
    end

    # 2 Zeichen  Art der Transaktionen
    # "LB" für Lastschriften Bankseitig
    # "LK" für Lastschriften Kundenseitig
    # "GB" für Gutschriften Bankseitig
    # "GK" für Gutschriften Kundenseitig
    #
    def typ
     'LK'
    end

    # Eine Buchung hinzufügen.
    # Es wird geprüft, ob das Vorzeichen identisch mit den bisherigen Vorzeichen ist.
    #
    def add(buchung)
      raise DtausException.new("Buchung expected, got #{buchung.class}") unless buchung.is_a?(Buchung)
      # Die erste Buchung bestimmt, ob alle Beträge positiv oder negativ sind.
      if buchungen == []
        @positiv = buchung.positiv? # alle Beträge sind positiv. Variable wird mit erstem Eintrag geändert
      end
      raise DtausException.new("Das Vorzeichen wechselte") if @positiv != buchung.positiv?
      @buchungen << buchung
    end

    # Gibt die DTAUS-Datei als String zurück
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
    # Standarddateiname ist DTAUS0.TXT
    #
    def to_file(filename ='DTAUS0.TXT')
      File.open(filename, 'w') do |file|
        file << to_dta
      end
    end

  private

    # Checksumme der Kontonummern
    #
    def checksum_konto
      @buchungen.inject(0){|sum, buchung| sum += buchung.konto.nummer}
    end

    # Checksumme der Bankleitzahlen
    #
    def checksum_blz
      @buchungen.inject(0){|sum, buchung| sum += buchung.konto.blz}
    end

    # Checksumme der Beträge
    #
    def checksum_betrag
      @buchungen.inject(0){|sum, buchung| sum += buchung.betrag}
    end

    # Erstellt A-Segment der DTAUS-Datei
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
    def dataA( )
      dta = '0128'                             #  4 Zeichen  Länge des Datensatzes, immer 128 Bytes, also immer "0128"
      dta += 'A'                               #  1 Zeichen  Datensatz-Typ, immer 'A'
      dta += typ                               #  2 Zeichen  Art der Transaktionen
      dta += '%8i' % auftraggeber.blz          #  8 Zeichen  Bankleitzahl des Auftraggebers
      dta += '%08i' % 0                        #  8 Zeichen  CST, "00000000", nur belegt, wenn Diskettenabsender Kreditinstitut
      dta += '%-27.27s' % auftraggeber.name    # 27 Zeichen  Name des Auftraggebers
      dta += @datum.strftime("%d%m%y")         #  6 Zeichen  aktuelles Datum im Format DDMMJJ
      dta += ' ' * 4                           #  4 Zeichen  CST, "    " (Blanks)
      dta += '%010i' % auftraggeber.nummer     # 10 Zeichen  Kontonummer des Auftraggebers
      dta += '%010i' % 0                       # 10 Zeichen  Optionale Referenznummer
      dta += ' '  * 15                         # 15 Zeichen  Reserviert, 15 Blanks
      dta += '%8s' % @datum.strftime("%d%m%Y") #  8 Zeichen  Optionales Ausführungsdatum im Format DDMMJJJJ. Nicht jünger als Erstellungsdatum (A7), jedoch höchstens 15 Kalendertage später. Sonst Blanks.
      dta += ' ' * 24                          # 24 Zeichen  Reserviert, 24 Blanks
      dta += '1'                               #  1 Zeichen  Währungskennzeichen ('1' = Euro)
      raise IncorrectSizeException.new("A-Segment: #{dta.size} Zeichen, 128 erwartet.") if dta.size != 128
      return dta
    end

    # Erstellt E-Segment (Prüfsummen) der DTAUS-Datei
    # Aufbau:
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
    def dataE()
      dta  = '0128'                    #  4 Zeichen  Länge des Datensatzes, immer 128 Bytes, also immer "0128"
      dta += 'E'                       #  1 Zeichen  Datensatz-Typ, immer 'E'
      dta += ' ' * 5                   #  5 Zeichen  5 Blanks
      dta += '%07i' % @buchungen.size  #  7 Zeichen  Anzahl der Datensätze vom Typ C
      dta += '0' * 13                  # 13 Zeichen  Kontrollsumme Beträge in DM
      dta += '%017i' % checksum_konto  # 17 Zeichen  Kontrollsumme Kontonummern
      dta += '%017i' % checksum_blz    # 17 Zeichen  Kontrollsumme Bankleitzahlen
      dta += '%013i' % checksum_betrag # 13 Zeichen  Kontrollsumme Beträge in Euro
      dta += ' '  * 51                 # 51 Zeichen  51 Blanks
      raise IncorrectSize.new("E-Segment: #{dta.size}, 128 erwartet") if dta.size != 128
      return dta
    end

  end
end