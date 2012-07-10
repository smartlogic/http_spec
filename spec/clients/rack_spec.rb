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

  it "issues requests to the app" do
    request = HTTPSpec::Request.new(:get, "/path")
    response = client.dispatch(request)
    response.body.should match(/^REQUEST_METHOD: GET$/)
    response.body.should match(/^PATH_INFO: \/path$/)
  end

  it "accepts query parameters as part of the path" do
    request = HTTPSpec::Request.new(:get, "/path?query=string")
    response = client.dispatch(request)
    response.body.should match(/^QUERY_STRING: query=string$/)
  end

  it "sends the response body as input" do
    request = HTTPSpec::Request.new(:post, "/path", "foobarbaz")
    response = client.dispatch(request)
    response.body.should match(/^rack.input: foobarbaz$/)
  end

  it "converts headers to env before requesting" do
    headers = {
      "Content-Type" => "x-foo-bar",
      "Content-Length" => "10",
      "X-Foo" => "Bar"
    }
    request = HTTPSpec::Request.new(:get, "/path", nil, headers)
    response = client.dispatch(request)
    response.body.should match(/^CONTENT_TYPE: x-foo-bar$/)
    response.body.should match(/^CONTENT_LENGTH: 10$/)
    response.body.should match(/^HTTP_X_FOO: Bar$/)
  end

  it "exposes the response status" do
    request = HTTPSpec::Request.new(:get, "/path")
    response = client.dispatch(request)
    response.status.should eq(200)
  end

  it "exposes the response headers" do
    request = HTTPSpec::Request.new(:get, "/path")
    response = client.dispatch(request)
    response.headers["X-Foo"].should eq("Bar")
  end
end
