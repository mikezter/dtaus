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
* Erstelle ein DTAUS Objekt für diesen Auftraggeber
* Erstelle ein oder mehrerere Kunden-Konten mit dazugehörigen Buchungen
* Füge die Buchungen dem DTAUS Objekt hinzu
* Schreibe eine DTAUS Datei
* _Alternativ:_ Gib die Daten als String aus

In Ruby:
 
    auftraggeber = DTAUS::Konto.new(1234567890, 12345670, 'Muster GmbH', 'Deutsche Bank', true)

    dta = DTAUS.new(auftraggeber)

    kunde = DTAUS::Konto.new(1234567890, 12345670, 'Max Meier-Schulze', 'Sparkasse')
    buchung = DTAUS::Buchung.new(auftraggeber, kunde, 39.99, 'Vielen Dank für ihren Einkauf vom 01.01.2010. Rechnungsnummer 12345')

    dta.add(buchung)

    dta.to_file

    puts dta

 
Einschränkungen:
----------------

* Es sind nur Lastschriften möglich. __Typ der Datei ist LK__ (Lastschrift Kunde).
* Auftraggeber, Empfänger und Verwendungszweck können jeweils 27 Zeichen enthalten. Es stehen 15 Erweiterungen à 27 Zeichen zur Verfügung. Jede Erweiterung kann entweder Auftraggeber, Empfänger oder Verwendungszweck erweitern.

Todo:
------

* Gutschriften ermöglichen
* Parameter als Hash annehmen (vor allem für `Konto` und `Buchung`)
* weiteres?

Weitere Informationen
---------------------

Infos zu DTAUS: http://www.infodrom.org/projects/dtaus/dtaus.html

DTAUS online check: http://www.xpecto.de/index.php?id=148,7

