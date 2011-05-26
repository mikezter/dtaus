# encoding: utf-8

module DTAUS

  # Buchungsdaten mit zwei Konten (Auftraggeber und Kunde),
  # Betrag und Verwendungszweck
  class Buchung

    attr_reader :betrag, :kunden_konto, :auftraggeber_konto, :verwendungszweck, :positiv, :transaktionstyp
    alias :positiv? :positiv

    # Buchung erstellen
    #
    # +params+ as Hash:
    # [<tt>:kunden_konto</tt>] DTAUS::Konto des Kunden
    # [<tt>:betrag</tt>] der Betrag der Buchung in +Float+
    # [<tt>:transaktionstyp</tt>] Art der Transaktion
    #                             * <tt>:lastschrift</tt> Lastschrift des Einzugsermächtigungsverfahren
    #                             * <tt>:gutschrift</tt> Überweisungs-Gutschrift
    #                             _optional_, Default-Wert ist <tt>:lastschrift</tt>
    # [<tt>:verwendungszweck</tt>] der Verwendungszweck der Buchung; _optional_, Default-Wert ist ""
    def initialize(params = {})
      # defaults
      params = {
        :transaktionstyp => :lastschrift,
        :verwendungszweck => ''
      }.merge(params)

      [:betrag, :kunden_konto].each do |attr|
        raise ArgumentError.new("Missing params[:#{attr}] for new Buchung.") if params[attr].nil?
      end

      unless params[:kunden_konto].is_a?(Konto)
        raise DtausException.new("Konto expected for Parameter 'kunden_konto', got #{params[:kunden_konto].class}")
      end
      unless [:lastschrift, :gutschrift].include?(params[:transaktionstyp])
        raise DtausException.new("Transaktionstyp has to be one of [:lastschrift, :gutschrift]")
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
      @transaktionstyp    = params[:transaktionstyp]
      @verwendungszweck   = Converter.convert_text(params[:verwendungszweck])

      if erweiterungen.size > 15
        raise IncorrectSizeException.new("Zuviele Erweiterungen: #{erweiterungen.size}, maximal 15. Verwendungszweck zu lang?")
      end

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
