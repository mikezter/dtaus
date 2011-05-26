class DTAUS
  class Validator
    attr_reader :string

    def self.load(filename)
      new(File.open(filename).read)
    end

    def initialize(string)
      @string = string
    end

    def a_satz
      @a_satz = ASatz.new(@string[0..127])
    end

    def e_satz
      @e_satz = ESatz.new(@string[-128..-1])
    end

    def c_saetze
      @c_saetze = CSatz.many(@string[128..-129])
    end
  end

  class Satz
    attr_reader :string

    def initialize(string)
      @string = string
    end

    def satzlaenge
      @string[0..3]
    end

    def satzart
      @string[4..4]
    end
  end

  class CSatz < Satz
    def self.many(string)
      this = new(string)
      anzahl_erweiterungen = this.anzahl_erweiterungen.to_i

      if anzahl_erweiterungen < 3
        offset = 0
      else
        anzahl_bloecke = ((anzahl_erweiterungen - 2) / 2) + anzahl_erweiterungen % 2
        offset = anzahl_bloecke * 128
      end

      return [this] if string[255 + offset..-1].nil?
      return [this] + many(string[255 + offset..-1])

    end

    def blz_erstbeteiligte_bank
      @string[5..12]
    end

    def blz_empfaenger
      @string[13..20]
    end

    def konto_empfaenger
      @string[21..30]
    end

    def interne_kundennummer
      @string[31..43]
    end

    def textschluessel
      @string[44..45]
    end

    def ergaenzung
      @string[46..48]
    end

    def leerzeichen1
      @string[49..50]
    end

    def nullen
      @string[50..60]
    end

    def blz_absender
      @string[61..68]
    end

    def konto_absender
      @string[69..78]
    end

    def betrag
      @string[79..89]
    end

    def leerzeichen2
      @string[90..92]
    end

    def name_empfaenger
      @string[93..119]
    end

    def leerzeichen3
      @string[120..127]
    end

    def name_absender
      @string[128..154]
    end

    def verwendungszweck
      @string[155..181]
    end

    def waehrung
      @string[182..182]
    end

    def leerzeichen4
      @string[183..184]
    end

    def anzahl_erweiterungen
      @string[185..186]
    end

    def interne_erweiterungen
      @string[187..244]
    end

    def leerzeichen5
      @string[245..255]
    end
  end

  class ESatz < Satz

    def leerzeichen1
      @string[5..9]
    end

    def anzahl_c_saetze
      @string[10..16]
    end

    def summe_dm
      @string[17..29]
    end

    def summe_konto
      @string[30..46]
    end

    def summe_blz
      @string[47..63]
    end

    def summe_euro
      @string[64..76]
    end

    def leerzeichen2
      @string[77..127]
    end
  end

  class ASatz < Satz

    def kennzeichen
      @string[5..6]
    end

    def blz_empfaenger
      @string[7..14]
    end

    def blz_absender
      @string[15..22]
    end

    def name_absender
      @string[23..49]
    end

    def erstellt_am
      @string[50..55]
    end

    def leerzeichen1
      @string[56..59]
    end

    def konto_absender
      @string[60..69]
    end

    def sammel_referenznummer
      @string[70..79]
    end

    def leerzeichen2
      @string[80..126]
    end

    def waehrung
      @string[127..127]
    end
  end
end