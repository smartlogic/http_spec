require "spec_helper"
require "http_spec/clients/faraday"

describe HTTPSpec::Clients::Faraday do
  let(:conn) do
    Faraday.new do |config|
      config.adapter :test do |stub|
        stub.get "/path"  do |req|
          headers = req[:request_headers]
          headers["Query"] = req[:params]["query"]
          [200, headers, req[:body]]
        end
      end
    end
  end

  let(:client) { HTTPSpec::Clients::Faraday.new(conn) }

  it "issues requests to the app" do
    request = HTTPSpec::Request.new(:get, "/path")
    response = client.dispatch(request)
    response.status.should eq(200)
  end

  it "passes through the request body" do
    request = HTTPSpec::Request.new(:get, "/path", "hello")
    response = client.dispatch(request)
    response.body.should eq("hello")
  end

  it "passes through the request headers" do
    request = HTTPSpec::Request.new(:get, "/path", nil, "Foo" => "Bar")
    response = client.dispatch(request)
    response.headers["Foo"].should eq("Bar")
  end

  it "accepts query parameters as part of the path" do
    request = HTTPSpec::Request.new(:get, "/path?query=string")
    response = client.dispatch(request)
    response.headers["Query"].should eq("string")
  end
end
