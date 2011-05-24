Gem::Specification.new do |s|
  s.name = "dtaus"
  s.version = "0.2.0"
  s.date = "2011-05-23"
  s.authors = ["mikezter", "alphaone"]
  s.email = "mikezter@gmail.com"
  s.summary = "DTAUS allows to easily create DTAUS files for the german banking sector"
  s.homepage = "http://github.com/alphaone/dtaus"
  s.description = "Beim Datenträgeraustausch (DTA) werden Zahlungsverkehrsdaten - also Überweisungen und Lastschriften - als Datei an ein Geldinstitut übergeben. Dieser Gem stellt Klassen bereit solche Dateien zu erzeugen."
  s.files = %w(README.markdown LICENSE Rakefile)
  s.files += Dir['lib/**/*.rb'] + Dir['example/**/*.rb']
  s.test_files = Dir.glob('test/*_test.rb') 
end