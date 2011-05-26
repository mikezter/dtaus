# encoding: utf-8

module DTAUS
  
  # Generische Exception für Dtaus
  class DtausException < Exception; end;

  # Exception für zu lange oder zu kurze DTA-Teile
  class IncorrectSizeException < DtausException; end;
  
  # Exception für falsch übergebene Typen bei Erweiterungen
  class IncorrectErweiterungTypeException < DtausException; end;
  
end