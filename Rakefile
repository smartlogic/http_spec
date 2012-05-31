require "rspec/core/rake_task"
require "cane/rake_task"

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

if RUBY_ENGINE == "ruby"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 10
    cane.style_measure = 80
    cane.no_doc = true
    cane.add_threshold 'coverage/covered_percent', :>=, 100
  end

  task :default => :quality
end
