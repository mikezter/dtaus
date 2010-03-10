class DTAUS
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

    class IncorrectErweiterungType; end;
    attr_reader :type, :text

    # Erstellt ein Array von Erweiterungen aus einem beliebig langem String
    #
    def self.from_string(_typ, _text)
      erweiterungen = []
      _text = DTAUS.convert_text(_text)
      if _text.size > 27
        index = 27
        while index < _text.size
          erweiterungen << Erweiterung.new(_typ, _text[index..index += 26])
        end
      end
      erweiterungen
    end

    # erweiterung = Erweiterung.new(:verwendungszweck, 'Rechnung Nr 12345')
    # _type muss ein Symbol aus :kunde, :verwendungszweck, :auftraggeber sein.
    #
    def initialize(_type, _text)
      raise IncorrectErweiterungType.new unless TYPES.keys.include?(_type) or TYPES.values.include?(_type)
      @text = DTAUS.convert_text(_text).ljust(27)
      raise IncorrectSize.new("Text size may not exceed 27 Chars") if text.size > 27
      @type = TYPES[_type] || _type
    end

    def to_dta
      "#{type}#{text}"
    end

  end

end

