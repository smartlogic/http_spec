require "aruba/cucumber"
require "capybara"
require "raddocs"

Before do
  @aruba_timeout_seconds = 5
end

Raddocs.configure do |config|
  config.docs_dir = "tmp/aruba/docs"
end
