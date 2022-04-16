require_relative 'lib/io-dispatcher/version'

Gem::Specification.new do |s|
  s.name          = 'io-dispatcher'
  s.version       = IO::Dispatcher::VERSION
  s.summary       = 'Simple dispatcher for IO objects.'
  s.author        = 'John Labovitz'
  s.email         = 'johnl@johnlabovitz.com'
  s.description   = %q{
    IO::Dispatcher is a simple dispatcher for IO objects.
  }
  s.license       = 'MIT'
  s.homepage      = 'http://github.com/jslabovitz/io-dispatcher'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path  = 'lib'

  s.add_development_dependency 'rake', '~> 13.0'
end