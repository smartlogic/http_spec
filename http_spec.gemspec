Gem::Specification.new do |s|
  s.name = "http_spec"
  s.version = "0.4.0"
  s.platform = Gem::Platform::RUBY
  s.summary = "RSpec DSL for describing API behaviors"
  s.homepage = "https://github.com/smartlogic/http_spec"
  s.author = "Sam Goldman"
  s.files = Dir["lib/**/*"]
  s.require_path = "lib"

  s.add_runtime_dependency "rspec-core"
  s.add_runtime_dependency "values"

  s.add_development_dependency "rack"
  s.add_development_dependency "webmachine"
  s.add_development_dependency "faraday"
  s.add_development_dependency "fdoc"
  s.add_development_dependency "raddocs"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "cane"
  s.add_development_dependency "capybara"
  s.add_development_dependency "aruba"
  s.add_development_dependency "coveralls"
end
