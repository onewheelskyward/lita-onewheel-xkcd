Gem::Specification.new do |spec|
  spec.name          = 'lita-onewheel-xkcd'
  spec.version       = '0.0.0'
  spec.authors       = ['Andrew Kreps']
  spec.email         = ['andrew.kreps@gmail.com']
  spec.description   = 'XKCD searchable archive for comics by keyword, id and date*.  * date coming soon to a minor update near you'
  spec.summary       = 'Ever wanted a way to display XKCD comics in your chat client of choice?  Look no further!'
  spec.homepage      = 'https://github.com/onewheelskyward/lita-onewheel-xkcd'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '~> 4.6'
  spec.add_runtime_dependency 'lita-irc', '~> 2.0'
  spec.add_runtime_dependency 'sequel', '~> 4.27'
  spec.add_runtime_dependency 'sequel_pg', '~> 1.6'
  spec.add_runtime_dependency 'pg', '~> 0.18'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rack-test', '~> 0.6'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end
