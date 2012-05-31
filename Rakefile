require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |config|
  # Add command line option to ensure that SimpleCov will be loaded first.
  # Otherwise, the first spec file run will not be covered.
  config.ruby_opts = "-r ./spec/spec_helper"
end

task :coverage do
  ENV["COVERAGE"] = "true"
  Rake::Task[:spec].execute
end

task :default => :coverage
