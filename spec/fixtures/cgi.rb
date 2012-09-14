#!/usr/bin/env ruby

require "cgi"
require "yaml"

cgi = CGI.new

cgi.out("nph" => true, "type" => "text/yaml", "status" => "OK") do
  if cgi.request_method == "GET"
    YAML.dump(ENV.to_hash)
  else
    YAML.dump(cgi.params)
  end
end
