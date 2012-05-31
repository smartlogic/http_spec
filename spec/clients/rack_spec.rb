require "spec_helper"
require "http_spec/clients/rack"

describe HTTPSpec::Clients::Rack do
  def app
    lambda do |env|
      request_body = env["rack.input"].read
      response_body = env.map { |k, v| "#{k}: #{v}\n" }
      response_body << "rack.input: #{request_body}"
      [200, {"X-Foo" => "Bar"}, response_body]
    end
  end

  let(:client) { HTTPSpec::Clients::Rack.new(app) }

  def response_lines
    client.response_body.split("\n")
  end

  it "issues requests to the app" do
    [:get, :post, :put, :delete, :options, :head].each do |method|
      http_method = method.to_s.upcase
      client.send(method, "/path")
      response_lines.should include("REQUEST_METHOD: #{http_method}")
      response_lines.should include("PATH_INFO: /path")
    end
  end

  it "accepts query parameters as part of the path" do
    client.get("/path?query=string")
    response_lines.should include("QUERY_STRING: query=string")
  end

  it "sends the response body as input" do
    client.post("/path", "foobarbaz")
    response_lines.should include("rack.input: foobarbaz")
  end

  it "converts headers to env before requesting" do
    headers = {
      "Content-Type" => "x-foo-bar",
      "Content-Length" => "10",
      "X-Foo" => "Bar"
    }
    client.get("/path", nil, headers)
    response_lines.should include("CONTENT_TYPE: x-foo-bar")
    response_lines.should include("CONTENT_LENGTH: 10")
    response_lines.should include("HTTP_X_FOO: Bar")
  end

  it "exposes the response status" do
    client.get("/path")
    client.status.should eq(200)
  end

  it "exposes the response headers" do
    client.get("/path")
    client.response_headers["X-Foo"].should eq("Bar")
  end
end
