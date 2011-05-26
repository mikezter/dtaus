# encoding: utf-8

module DTAUS

  # Eine Erweiterung eines C-Segments
  # Stellt eine Länge von 27 Zeichen sicher
  #
  class Erweiterung
    TYPE_KUNDE            = '01'
    TYPE_VERWENDUNGZWECK  = '02'
    TYPE_AUFTRAGGEBER     = '03'

    TYPES = {
      :kunde => TYPE_KUNDE,
      :verwendungszweck => TYPE_VERWENDUNGZWECK,
      :auftraggeber => TYPE_AUFTRAGGEBER
    }

    attr_reader :type, :text

    # Erstellt eine Erweiterung
    #
    # [<tt>_text</tt>] ist ein beliebig langer String
    # [<tt>_type</tt>] muss ein Symbol sein, aus: 
    #                  <tt>:kunde</tt>, <tt>:verwendungszweck</tt>, <tt>:auftraggeber</tt>
    #
    def initialize(_type, _text)
      unless TYPES.keys.include?(_type) or TYPES.values.include?(_type)
        raise IncorrectErweiterungTypeException.new("Allowed types: :kunde, :verwendungszweck, :auftraggeber") 
      end
      @text = Converter.convert_text(_text).ljust(27)
      if text.size > 27
        raise IncorrectSizeException.new("Text size may not exceed 27 Chars") 
      end
      @type = TYPES[_type] || _type
    end

    # Erstellt aus einem beliebig langem String eine Liste von Erweiterungen,
    # wenn dies nötig wird.
    # Es werden nur Erweiterungen für den Teil von <tt>_text</tt> erzeugt, der
    # nicht in das Standardfeld von 27 Zeichen passt.
    # Keine Erweiterungen werden erzeugt, wenn der <tt>_text</tt> vollständig
    # in das Standardfeld von 27 Zeichen passt.
    #
    # [<tt>_text</tt>] ist ein beliebig langer String
    # [<tt>_type</tt>] muss ein Symbol sein, aus: 
    #                  <tt>:kunde</tt>, <tt>:verwendungszweck</tt>, <tt>:auftraggeber</tt>
    #
    # returns: Array of Erweiterung
    def self.from_string(_type, _text)
      erweiterungen = []
      _text = Converter.convert_text(_text)
      
      # first slice will be omitted
      _text.slice!(0..26) 
      
      while _text.size > 0
        erweiterungen << Erweiterung.new(_type, _text.slice!(0..26))
      end
      erweiterungen
    end

  end

end
