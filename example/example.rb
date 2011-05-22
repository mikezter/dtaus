ROOT = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'dtaus')

require 'dtaus'

auftraggeber = Dtaus::Konto.new(1234567890, 12345670, 'Muster GmbH', 'Deutsche Bank', true)

dta = Dtaus::DtaGenerator.new(auftraggeber)

kunde = Dtaus::Konto.new(1234567890, 12345670, 'Max Meier-Schulze', 'Sparkasse')
buchung = Dtaus::Buchung.new(auftraggeber, kunde, 39.99, 'Vielen Dank für ihren Einkauf vom 01.01.2010. Rechnungsnummer 12345')

dta.add(buchung)

dta.to_file

puts dta