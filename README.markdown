DTAUS
=====

This is a library specific to the german banking sector. Therefore the documentation will be in german. If you have any questions please feel free to email me at mikezter@gmail.com

Beim Datenträgeraustausch (DTA) werden Zahlungsverkehrsdaten - also Überweisungen und Lastschriften - als Datei an ein Geldinstitut übergeben. Dieser Gem stellt Klassen bereit solche Dateien zu erzeugen.

Download
-------------

Install via RubyGems: `gem install dtaus`

Usage
-------------

Ablauf:

* Erstelle ein Auftraggeber-Konto 
* Erstelle ein Datensatz für diesen Auftraggeber
* Erstelle ein oder mehrerere Kunden-Konten mit dazugehörigen Buchungen
* Füge die Buchungen dem Datensatz hinzu
* Schreibe den Datensatz als DTAUS Datei
* _Alternativ:_ Gib die Daten als String aus

In Ruby:
 
``` ruby
require 'dtaus'

# Konto des Auftraggebers
konto_auftraggeber = DTAUS::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 82070024, 
  :kontoinhaber => 'inoxio Quality Services GmbH', 
  :bankname =>'Deutsche Bank',
  :is_auftraggeber => true
)

# LASTSCHRIFT
# Erstellen eines Datensatzes für eine Lastschrift
lastschrift = DTAUS::Datensatz.new(:lastschrift, konto_auftraggeber)

# Konto des Kunden
konto_kunde = DTAUS::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 12030000, 
  :kontoinhaber => 'Max Meier-Schulze', 
  :bankname =>'Sparkasse',
  :kundennummer => 77777777777
)
# Lastschrift-Buchung für den Kunden
buchung = DTAUS::Buchung.new(
  :kunden_konto => konto_kunde,
  :betrag => "9,99",
  :transaktionstyp => :lastschrift,
  :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
)
lastschrift.add(buchung)

lastschrift.to_file
puts lastschrift
```

Siehe: [example/example.rb](https://github.com/alphaone/dtaus/blob/master/example/example.rb)
 
Einschränkungen:
----------------

* Es sind nur Lastschriften und Gutschriften möglich. __Typ der Datei ist LK oder GK__ (Lastschrift-Kunde oder Gutschrift-Kunde).
* Auftraggeber, Empfänger und Verwendungszweck können jeweils 27 Zeichen enthalten. Es stehen 15 Erweiterungen à 27 Zeichen zur Verfügung. Jede Erweiterung kann entweder Auftraggeber, Empfänger oder Verwendungszweck erweitern.

Weitere Informationen
---------------------
Ursprung: http://ruby.lickert.net/dtaus/

Infos zu DTAUS: http://www.infodrom.org/projects/dtaus/dtaus.html

DTAUS online check: http://www.xpecto.de/index.php?id=148,7

Formatbeschreibung der Kreissparkasse Köln (pdf) https://www.ksk-koeln.de/formatbeschreibung_datentraegeraustausch.pdfx


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/mikezter/dtaus/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

