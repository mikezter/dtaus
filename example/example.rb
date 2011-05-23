ROOT = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'dtaus')

require 'dtaus'

konto_auftraggeber = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 12345678, 
  :kontoinhaber => 'Muster GmbH', 
  :bankname =>'Deutsche Bank',
  :is_auftraggeber => true,
  :kundennummer => 12345
)
dta = Dtaus::Datensatz.new(konto_auftraggeber)

konto_kunde = Dtaus::Konto.new(
  :kontonummer => 1234567890, 
  :blz => 12345678, 
  :kontoinhaber => 'Max Meier-Schulze', 
  :bankname =>'Sparkasse'
)
buchung = Dtaus::Buchung.new(konto_auftraggeber, konto_kunde, 39.99, 'Vielen Dank für ihren Einkauf')
dta.add(buchung)

dta.to_file
puts dta
