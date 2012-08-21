if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.formatter = Class.new do
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      File.open("coverage/covered_percent", "w") do |f|
        f.puts result.source_files.covered_percent.to_f
      end
    end
  end

  SimpleCov.start
end

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each &method(:require)

def mock_client(&block)
  client = stub
  client.stub(:dispatch, &block)
  client
end
