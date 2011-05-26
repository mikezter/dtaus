# encoding: utf-8

module DTAUS
  
  # Generische Exception für Dtaus
  class DTAUSException < Exception; end;

  # Exception für zu lange oder zu kurze DTA-Teile
  class IncorrectSizeException < DTAUSException; end;
  
  # Exception für falsch übergebene Typen bei Erweiterungen
  class IncorrectErweiterungTypeException < DTAUSException; end;
  
end