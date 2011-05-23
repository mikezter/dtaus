# encoding: utf-8

module Dtaus

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

    # Erstellt ein Array von Erweiterungen aus einem beliebig langem String
    #
    # _text ist ein beliebig langer String
    # _type muss ein Symbol sein, aus :
    # * :kunde
    # * :verwendungszweck
    # * :auftraggeber
    #
    # returns: Array of Erweiterung
    def self.from_string(_type, _text)
      erweiterungen = []
      _text = Converter.convert_text(_text)
      while _text.size > 0
        erweiterungen << Erweiterung.new(_type, _text.slice!(0..26))
      end
      erweiterungen
    end

    # Erstellt eine Erweiterunge
    #
    # _text ist ein String mit maximaler Länge von 27 Zeichen
    # _type muss ein Symbol sein, aus :
    # * :kunde
    # * :verwendungszweck
    # * :auftraggeber
    #
    # returns: Erweiterung
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
    
    # Erstellt die DTA-Repräsentation einer Erweiterung
    def to_dta
      "#{type}#{text}"
    end

  end

end
