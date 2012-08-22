require "aruba/cucumber"
require "capybara"
require "raddocs"

Before do
  @aruba_timeout_seconds = 10
end

Raddocs.configure do |config|
  config.docs_dir = "tmp/aruba/docs"
end
