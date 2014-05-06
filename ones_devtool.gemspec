# encoding: utf-8
 require 'rake'
  lib = File.expand_path('../lib/', __FILE__)
  $:.unshift lib unless $:.include?(lib)
  require 'ones_devtool'
 
 Gem::Specification.new do |s|
   s.files = FileList['lib/**/*',
                        'bin/*',
                        '[A-Z]*',
                        'ext/**/*'].to_a
  s.executables = []
  Dir.glob('bin/*'){|f| s.executables << File.basename(f)}
  s.name        = Version::NAME
  s.version     = Version::VERSION
  s.platform    = Gem::Platform::CURRENT
  s.date        = Time.now.strftime '%Y-%m-%d'
  s.summary     = "Утилиты 1С разработчика"
  s.description = "Утилиты 1С разработчика"
  s.authors     = ["Leonid Vlasov"]
  s.email       = 'leo@asscode.ru'
  s.homepage    = 'http://rm.asscode.ru/projects/ru-asscode-ones-devtool'
  s.license     = 'MIT'
end