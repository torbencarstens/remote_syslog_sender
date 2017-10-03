Gem::Specification.new do |s|
  s.name              = 'remote_syslog_logger'
  s.version           = '1.0.3'
  s.summary     = "Ruby Logger that sends directly to a remote syslog endpoint"
  s.description = "A ruby Logger that sends UDP directly to a remote syslog endpoint"

  s.authors  = ["Eric Lindvall"]
  s.email    = 'eric@5stops.com'
  s.homepage = 'https://github.com/papertrail/remote_syslog_logger'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_runtime_dependency 'syslog_protocol'

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
end
