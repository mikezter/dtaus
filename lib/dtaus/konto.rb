# encoding: utf-8

module DTAUS

  # Kontodaten mit Name des Inhabers, Bank, Bankleitzahl und Kontonummer.
  # Kann zwischen Auftraggeber und Kundenkonto unterscheiden.
  class Konto
    attr_reader  :blz, :bankname, :kontoinhaber, :kundennummer, :is_auftraggeber, :kontonummer

    alias :is_auftraggeber? :is_auftraggeber
    
    # Erstellt ein neues Konto
    #
    # +params+ as Hash:
    # [<tt>:kontonummer</tt>] die Kontonummer
    # [<tt>:blz</tt>] die Bankleitzahl
    # [<tt>:kontoinhaber</tt>] der Name der Kontoinhabers
    # [<tt>:bankname</tt>] der Name der Bank
    # [<tt>:is_auftraggeber</tt>] Boolischer Wert, ob dieses Konto ein Auftraggeberkonto ist;
    #                             wird gebraucht, um den Typ der Erweiterung zu bestimmen;
    #                             _optional_, default-Wert ist +false+
    # [<tt>:kundennummer</tt>] eine Kundennummer; _optional_, defautl-Wert ist <tt>0</tt>
    def initialize(params = {})
      # defaults
      params = {
        :is_auftraggeber => false,
        :kundennummer => 0
      }.merge(params)
      
      [:blz, :bankname, :kontoinhaber, :kontonummer].each do |attr|
        raise ArgumentError.new("Missing params[:#{attr}] for new Konto.") if params[attr].nil?
      end
      
      @is_auftraggeber = params[:is_auftraggeber]

      @kontonummer  = Converter.convert_number(params[:kontonummer])
      @blz          = Converter.convert_number(params[:blz])
      @kundennummer = Converter.convert_number(params[:kundennummer])
      @kontoinhaber = Converter.convert_text(params[:kontoinhaber])
      @bankname     = Converter.convert_text(params[:bankname])

      if @kontonummer == 0 or @kontonummer.to_s.size > 10
        raise DTAUSException.new("Ungültige Kontonummer: #{@kontonummer}") 
      end
      if @blz  == 0 or @blz.to_s.size > 8
        raise DTAUSException.new("Ungültige Bankleitzahl: #{@blz}")   
      end
      if @kundennummer.to_s.size > 11
        raise DTAUSException.new("Ungültige Kundennummer: #{@kundennummer}")   
      end
      
    end
    
    # Erstellt eine Liste von Erweiterungen für den Kontoinhaber
    def erweiterungen
      Erweiterung.from_string(is_auftraggeber? ? :auftraggeber : :kunde, kontoinhaber)
    end

  end
end
