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
    def self.from_string(_typ, _text)
      erweiterungen = []
      _text = Converter.convert_text(_text)
      while _text.size > 0
        erweiterungen << Erweiterung.new(_typ, _text.slice!(0..26))
      end
      erweiterungen
    end

    # erweiterung = Erweiterung.new(:verwendungszweck, 'Rechnung Nr 12345')
    # _type muss ein Symbol aus :kunde, :verwendungszweck, :auftraggeber sein.
    #
    def initialize(_type, _text)
      raise IncorrectErweiterungTypeException.new unless TYPES.keys.include?(_type) or TYPES.values.include?(_type)
      @text = Converter.convert_text(_text).ljust(27)
      raise IncorrectSizeException.new("Text size may not exceed 27 Chars") if text.size > 27
      @type = TYPES[_type] || _type
    end

    def to_dta
      "#{type}#{text}"
    end

  end

end
