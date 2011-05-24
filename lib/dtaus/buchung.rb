# encoding: utf-8

module Dtaus

  # Buchungsdaten mit zwei Konten (Auftraggeber und Kunde),
  # Betrag und Verwendungszweck
  class Buchung
    
    attr_reader :betrag, :kunden_konto, :auftraggeber_konto, :verwendungszweck, :positiv
    alias :positiv? :positiv

    # Buchung erstellen
    #
    # +params+ as Hash:
    # [<tt>:kunden_konto</tt>] Dtaus::Konto des Kunden
    # [<tt>:betrag</tt>] der Betrag der Buchung in +Float+
    # [<tt>:verwendungszweck</tt>] der Verwendungszweck der Buchung; _optional_, Default-Wert ist ""
    def initialize(params = {})
      # defaults
      params = {
        :verwendungszweck => ''
      }.merge(params)

      [:betrag, :kunden_konto].each do |attr|
        raise ArgumentError.new("Missing params[:#{attr}] for new Buchung.") if params[attr].nil?
      end

      unless params[:kunden_konto].is_a?(Konto)
        raise DtausException.new("Konto expected for Parameter 'kunden_konto', got #{params[:kunden_konto].class}")
      end
      
      # betrag to BigDecimal
      if params[:betrag].is_a? String
        params[:betrag] = BigDecimal.new params[:betrag].sub(',', '.')
      elsif params[:betrag].is_a? Numeric
        params[:betrag] = BigDecimal.new params[:betrag].to_s
      else
        raise DtausException.new("Betrag is a #{params[:betrag].class}, expected String or Numeric")
      end
      
      # Betrag in Cent
      params[:betrag] = ( params[:betrag] * 100 ).to_i
      if params[:betrag] == 0
        raise DtausException.new("Betrag must not be 0.00 €!")
      elsif params[:betrag] > 0
        @betrag  = params[:betrag]
        @positiv = true
      else
        @betrag  = params[:betrag] * -1
        @positiv = false
      end

      @kunden_konto       = params[:kunden_konto]
      @verwendungszweck   = Converter.convert_text(params[:verwendungszweck])

      if erweiterungen.size > 15
        raise IncorrectSizeException.new("Zuviele Erweiterungen: #{erweiterungen.size}, maximal 15. Verwendungszweck zu lang?")
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
    #   Die im Textschlüssel mit XX bezeichnete Stelle ist 00 oder der Prozentsatz der Sparzulage.
    #   Die im Textschlüssel mit J bezeichnete Stelle wird bei Übernahme in eine Zahlung automatisch
    #   mit der jeweils aktuellen Jahresendziffer (z.B. 7, wenn 97) ersetzt.
    # * "56000" Überweisung öffentlicher Kassen
    def zahlungsart
      '05000'
    end

    # Alle Erweiterungen der Buchung, bestehend aus
    # * Inhaber Kundenkonto
    # * Verwendungszweck dieser Buchung
    #
    # Die Erweiterung für das auftraggeber_konto werden hier nicht aufgeführt!
    def erweiterungen
      kunden_konto.erweiterungen + 
      Erweiterung.from_string(:verwendungszweck, verwendungszweck)
    end
    
  end
end
