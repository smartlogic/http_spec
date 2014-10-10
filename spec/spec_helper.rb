if ENV["COVERAGE"]
  require "simplecov"
  require "coveralls"
  require "fileutils"

  class HTMLFormatterWithCoveredPercent
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      FileUtils.mkdir_p("coverage")
      File.open("coverage/covered_percent", "w+") do |f|
        f.puts result.source_files.covered_percent.to_f
      end
    end
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    HTMLFormatterWithCoveredPercent,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    root "lib"
  end
end

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each &method(:require)

def mock_client(&block)
  client = double
  allow(client).to receive(:dispatch, &block)
  client
end
