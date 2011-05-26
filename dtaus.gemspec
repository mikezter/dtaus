Gem::Specification.new do |s|
  s.name = %q{dtaus}
  s.version = "0.1.2"
  s.date = %q{2010-03-10}
  s.authors = ["mikezter"]
  s.email = %q{mikezter@gmail.com}
  s.summary = %q{DTAUS allows to easily create DTAUS files for the german banking sector}
  s.homepage = %q{http://github.com/mikezter/dtaus}
  s.description = %q{Beim Datenträgeraustausch (DTA) werden Zahlungsverkehrsdaten - also Überweisungen und Lastschriften - als Datei an ein Geldinstitut übergeben. Dieser Gem stellt Klassen bereit solche Dateien zu erzeugen.}
  s.files = %w(README.markdown LICENSE lib/dtaus.rb lib/dtaus/erweiterung.rb lib/dtaus/buchung.rb lib/dtaus/konto.rb)
end