# encoding: utf-8

module DTAUS
  
  # Utility class for converting strings and numbers to DTA-conform representations
  class Converter
    
    # Zeichen umsetzen gemäss DTA-Norm
    #
    def self.convert_text(_text)
      tmp = _text.to_s.dup
      tmp = tmp.upcase()
      tmp = tmp.gsub('Ä', 'AE')
      tmp = tmp.gsub('Ü', 'UE')
      tmp = tmp.gsub('Ö', 'OE')
      tmp = tmp.gsub('ä', 'AE')
      tmp = tmp.gsub('ü', 'UE')
      tmp = tmp.gsub('ö', 'OE')
      tmp = tmp.gsub('ß', 'SS')
      tmp = tmp.strip
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
    
  end
end