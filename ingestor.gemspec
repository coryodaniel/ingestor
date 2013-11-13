# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ingestor/version'

Gem::Specification.new do |gem|
  gem.name          = "ingestor"
  gem.version       = Ingestor::VERSION
  gem.authors       = ["Cory O'Daniel"]
  gem.email         = ["github@coryodaniel.com"]
  gem.description   = "Ingesting local and remote data files into ActiveRecord"
  gem.summary       = "Ingesting local and remote data files into ActiveRecord"
  gem.homepage      = "http://github.com/coryodaniel/ingestor"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "docile"
  gem.add_dependency "rubyzip", '< 1.0.0'
  gem.add_dependency "thor"
  gem.add_dependency "nokogiri", '> 1.5.6'
  #gem.add_dependency "activesupport", '>= 3.2.0'
  gem.add_dependency "activesupport"
  gem.add_dependency 'multi_json', '~> 1.0'
end
