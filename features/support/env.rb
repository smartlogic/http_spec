require "aruba/cucumber"
require "capybara"
require "raddocs"

Raddocs.configure do |config|
  config.docs_dir = "tmp/aruba/docs"
end
