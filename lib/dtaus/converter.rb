# encoding: utf-8

module DTAUS

  # Utility class for converting strings and numbers to DTA-conform representations
  class Converter

    # Zeichen umsetzen gemäss DTA-Norm
    #
    def self.convert_text(_text)
      _text.upcase!
      replacement_map.each { |rule| _text.gsub!(rule[:pattern], rule[:replacement]) }
      _text.strip
    end

    # Konvertiert einen String in einen Integer
    # indem alle Nicht-Digits entfernt werden.
    # Lässt Integer unberührt.
    #
    def self.convert_number(_number)
      case _number
        when Integer then _number
        when String then _number.strip.gsub(/\D/, '').to_i
        else raise DTAUSException.new("Cannot convert #{_number.class} to Integer")
      end
    end
  
  private
    
    def self.replacement_map
      [
        { :pattern => /[Ää]/u,                        :replacement => 'AE' },
        { :pattern => /[Öö]/u,                        :replacement => 'OE' },
        { :pattern => /[Üü]/u,                        :replacement => 'UE' },
        { :pattern => /[ß]/u,                         :replacement => 'SS' },
        { :pattern => /[^A-Z0-9 \.\,\&\-\/\+\*\$\%]/, :replacement => '' },
      ]
    end

  end
end