ROOT = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'dtaus')

require 'dtaus'

# Konto des Auftraggebers
konto_auftraggeber = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 82070024, 
  :kontoinhaber => 'inoxio Quality Services GmbH', 
  :bankname =>'Deutsche Bank',
  :is_auftraggeber => true
)

# GUTSCHRIFT
# Erstellen eines Datensatzes für eine Gutschrift
gutschrift = Dtaus::Datensatz.new(:gutschrift, konto_auftraggeber)

# Konto des Kunden
konto_kunde = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 12030000, 
  :kontoinhaber => 'Max Meier-Schulze', 
  :bankname =>'Sparkasse',
  :kundennummer => 77777777777
)
# Gutschrift-Buchung für den Kunden
buchung = Dtaus::Buchung.new(
  :kunden_konto => konto_kunde,
  :betrag => "9,99",
  :transaktionstyp => :gutschrift,
  :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
)
gutschrift.add(buchung)

gutschrift.to_file('gutschrift.txt')
puts gutschrift

# LASTSCHRIFT
# Erstellen eines Datensatzes für eine Lastschrift
lastschrift = Dtaus::Datensatz.new(:lastschrift, konto_auftraggeber)

# Konto des Kunden
konto_kunde = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 12030000, 
  :kontoinhaber => 'Max Meier-Schulze', 
  :bankname =>'Sparkasse',
  :kundennummer => 77777777777
)
# Lastschrift-Buchung für den Kunden
buchung = Dtaus::Buchung.new(
  :kunden_konto => konto_kunde,
  :betrag => "9,99",
  :transaktionstyp => :lastschrift,
  :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
)
lastschrift.add(buchung)

lastschrift.to_file('lastschrift.txt')
puts lastschrift

