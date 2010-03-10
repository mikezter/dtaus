DTAUS
=====

This is a library specific to the german banking sector. Therefore the documentation will be in german. If you have any questions please feel free to email me at mikezter@gmail.com

Beim Datenträgeraustausch (DTA) werden Zahlungsverkehrsdaten - also Überweisungen und Lastschriften - als Datei an ein Geldinstitut übergeben. Dieser Gem stellt Klassen bereit solche Dateien zu erzeugen.

How-To:
-------------

 * Erstelle ein Auftraggeber-Konto 
 
    auftraggeber = DTAUS::Konto.new(0123456789, 01234567, 'Muster GmbH', 'Deutsche Bank', true)
 * Erstelle ein DTAUS Objekt für diesen Auftraggeber
    dta = DTAUS.new(auftraggeber)
 * Erstelle ein oder mehrerere Kunden-Konten mit dazugehörigen Buchungen
    kunde = DTAUS::Konto.new(0123456789, 01234567, 'Max Meier-Schulze', 'Sparkasse')
    buchung = DTAUS::Buchung.new(auftraggeber, kunde, 39.99, 'Vielen Dank für ihren Einkauf vom 01.01.2010. Rechnungsnummer 12345')
 * Füge die Buchungen dem DTAUS Objekt hinzu
    dta.add(buchung)
 * Schreibe eine DTAUS Datei
    dta.to_file
 * _Alternativ:_ Gebe die Daten als String aus
    puts dta

Typ der Datei ist __LK__ (Lastschrift Kunde)
 
Einschränkungen:
----------------

 * Es sind nur Lastschriften möglich. 
 * Auftraggeber, Empfänger und Verwendungszweck können jeweils 27 Zeichen enthalten. Es stehen 15 Erweiterungen à 27 Zeichen zur Verfügung. Jede Erweiterung kann entweder Auftraggeber, Empfänger oder Verwendungszweck erweitern.

Todo:
------

 * Gutschriften ermöglichen
 * Refactor to Module instead of Class with Subclasses
 * Parameter als Hash annehmen (vor allem für `Konto` und `Buchung`)
 * weiteres?

Weitere Informationen
---------------------

Infos zu DTAUS: http://www.infodrom.org/projects/dtaus/dtaus.html
DTAUS online check: http://www.xpecto.de/index.php?id=148,7

