# encoding: utf-8

module Dtaus

  # Buchungsdaten mit zwei Konten (Auftraggeber und Kunde),
  # Betrag und erwendungszweck
  class Buchung
    attr_reader :betrag, :konto, :text, :positiv, :auftraggeber
    alias :positiv? :positiv

    # Buchung erstellen
    #
    # Parameter:
    # * _auftraggeber, Dtaus::Konto des Auftraggebers
    # * _konto, Dtaus::Konto des Kunden
    # * _betrag, der Betrag der Buchung in +Float+
    # * _text, der Verwendungszweck der Buchung,
    #          optional, default-Wert ist +""+
    def initialize(_auftraggeber, _konto, _betrag, _text = "")
      raise DtausException.new("Konto expected for Parameter 'konto', got #{_konto.class}") unless _konto.is_a?(Konto)
      raise DtausException.new("Konto expected for Parameter 'auftraggeber', got #{_auftraggeber.class}") unless _auftraggeber.is_a?(Konto)
      raise DtausException.new("Betrag is a #{_betrag.class}, expected Float") unless _betrag.is_a?(Float)
      raise DtausException.new("Betrag ist 0.0") if _betrag == 0

      @auftraggeber = _auftraggeber
      @konto        = _konto
      @text         = Converter.convert_text(_text)

      if erweiterungen.size > 15
        raise IncorrectSizeException.new("Zuviele Erweiterungen: #{erweiterungen.size}, maximal 15. Verwendungszweck zu lang?")
      end

      @betrag = (_betrag * 100).round.to_i  # Euro-Cent
      if betrag > 0
        @positiv  = true
      else
        @betrag   = -betrag # only store positive amounts
        @positiv  = false
      end
    end

    # Art der Transaktion (5 Zeichen, 7a: 2 Zeichen, 7b: 3 Zeichen)
    #
    # Zum Beispiel:
    # * "04000" Lastschrift des Abbuchungsauftragsverfahren
    # * "05000" Lastschrift des Einzugsermächtigungsverfahren
    # * "05005" Lastschrift aus Verfügung im elektronischen Cash-System
    # * "05006" Wie 05005 mit ausländischen Karten
    # * "05015" Lastschrift aus Verfügung im elec. Cash-System - POZ
    # * "51000" Überweisungs-Gutschrift
    # * "53000" Überweisung Lohn/Gehalt/Rente
    # * "54XXJ" Vermögenswirksame Leistung (VL) mit Sparzulage
    #           Die im Textschlüssel mit XX bezeichnete Stelle ist 00 oder der Prozentsatz der Sparzulage.
    #           Die im Textschlüssel mit J bezeichnete Stelle wird bei Übernahme in eine Zahlung automatisch
    #           mit der jeweils aktuellen Jahresendziffer (z.B. 7, wenn 97) ersetzt.
    # * "56000" Überweisung öffentlicher Kassen
    def zahlungsart
      '05000'
    end

    # Der Verwendungszweck als Dtaus::Erweiterung
    def verwendungszweck_erweiterungen
      Erweiterung.from_string(:verwendungszweck, text)
    end

    # Alle Erweiterungen der Buchung, bestehend aus
    # * Inhaber Kundenkonto
    # * Inhaber Auftraggeberkonto
    # * Verwendungszweck dieser Buchung
    def erweiterungen
      @erweiterungen ||= konto.erweiterungen + auftraggeber.erweiterungen + verwendungszweck_erweiterungen
    end

    # DTAUS-Repräsentation der Buchung
    def to_dta
      "#{dataC}#{dataC_erweiterungen}"
    end

    # Länge des DTA-Datensatzes
    def size
      (187 + erweiterungen.size * 29)
    end

  private

    # Erstellt den Erweiterungen-Teil des C-Segments für diese Buchung
    #
    def dataC_erweiterungen
      dta = auftraggeber.name[0..26].ljust(27) # 27 Zeichen  Name des Auftraggebers
      dta += text[0..26].ljust(27)             # 27 Zeichen  Verwendungszweck
      dta += '1'                               # 1 Zeichen  Währungskennzeichen ('1' = Euro)
      dta += '  '                              # 2 Zeichen   Reserviert, 2 Blanks
      dta += "%02i" % erweiterungen.size       # 2 Zeichen   Anzahl der Erweiterungsdatensätze, "00" bis "15"
      dta += erweiterungen[0..1].inject('') {|data, erweiterung| data += erweiterung.to_dta}
      dta = dta.ljust(128)
      if erweiterungen.size > 2
        erweiterungen[2..-1].each_slice(4) do |slice|
          dta += slice.inject('') {|dta, erweiterung| dta += erweiterung.to_dta}.ljust(128)
        end
      end
      
      if dta.size > 256 * 3 or dta.size % 128 != 0
        raise IncorrectSizeException.new("Erweiterungen: #{dta.size} Zeichen") 
      end
      
      dta
    end

    # Erstellt ein C-Segments für diese Buchung
    #
    def dataC
      dta  = '%04i' % size                         #  4 Zeichen  Länge des Datensatzes, 187 + x * 29 (x..Anzahl Erweiterungsteile)
      dta += 'C'                                   #  1 Zeichen  Datensatz-Typ, immer 'C'
      dta += '%08i' % 0                            #  8 Zeichen  Bankleitzahl des Auftraggebers (optional)
      dta += '%08i' % konto.blz                    #  8 Zeichen  Bankleitzahl des Kunden
      dta += '%010i' % konto.nummer                # 10 Zeichen  Kontonummer des Kunden
      dta += '0%011i0' % konto.kunnr               # 13 Zeichen  Verschiedenes 1. Zeichen: "0" 2. - 12. Zeichen: interne Kundennummer oder Nullen 13. Zeichen: "0"
      dta += zahlungsart                           #  5 Zeichen  Art der Transaktion (7a: 2 Zeichen, 7b: 3 Zeichen)
      dta += ' '                                   #  1 Zeichen  Reserviert, " " (Blank)
      dta += '0' * 11                              # 11 Zeichen  Betrag
      dta += '%08i' % auftraggeber.blz             #  8 Zeichen  Bankleitzahl des Auftraggebers
      dta += '%010i' % auftraggeber.nummer         # 10 Zeichen  Kontonummer des Auftraggebers
      dta += '%011i' % betrag                      # 11 Zeichen  Betrag in Euro einschließlich Nachkommastellen, nur belegt, wenn Euro als Währung angegeben wurde
      dta += ' ' * 3                               #  3 Zeichen  Reserviert, 3 Blanks
      dta += konto.name[0..26].ljust(27)           # 27 Zeichen  Name des Kunden
      dta +=  ' ' * 8                              #  8 Zeichen  Reserviert, 8 Blanks
      
      if dta.size != 128
        raise IncorrectSizeException.new("C-Segement 1: #{dta.size} Zeichen, 128 erwartet (#{konto.name})")
      end
      
      dta
    end

  end
end
