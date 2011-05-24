ROOT = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'dtaus')

require 'dtaus'

konto_auftraggeber = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 82070024, 
  :kontoinhaber => 'inoxio Quality Services GmbH', 
  :bankname =>'Deutsche Bank',
  :is_auftraggeber => true
)
dta = Dtaus::Datensatz.new(konto_auftraggeber)

konto_kunde = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 12030000, 
  :kontoinhaber => 'Max Meier-Schulze', 
  :bankname =>'Sparkasse',
  :kundennummer => 77777777777
)
buchung = Dtaus::Buchung.new(
  :kunden_konto => konto_kunde,
  :betrag => "9,99",
  :verwendungszweck => "Vielen Dank für Ihren Einkauf!"
)
dta.add(buchung)

dta.to_file
puts dta
