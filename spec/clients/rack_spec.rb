require "spec_helper"
require "http_spec/clients/rack"

describe HTTPSpec::Clients::Rack do
  def app
    lambda do |env|
      @env = env
      [200, { "Foo" => "Bar" }, ["hello"]]
    end
  end

  let(:client) { HTTPSpec::Clients::Rack.new(app) }

  it "issues requests to the app" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    client.dispatch(request)
    @env["REQUEST_METHOD"].should eq("GET")
    @env["PATH_INFO"].should eq("/path")
  end

  it "accepts query parameters as part of the path" do
    request = HTTPSpec::Request.new(:get, "/path?query=string", "", {})
    client.dispatch(request)
    @env["QUERY_STRING"].should eq("query=string")
  end

  it "sends the response body as input" do
    request = HTTPSpec::Request.new(:post, "/path", "foobarbaz", {})
    client.dispatch(request)
    @env["rack.input"].read.should eq("foobarbaz")
  end

  it "converts headers to env before requesting" do
    headers = {
      "Content-Type" => "x-foo-bar",
      "Content-Length" => "10",
      "Foo" => "Bar"
    }
    request = HTTPSpec::Request.new(:get, "/path", "", headers)
    client.dispatch(request)
    @env["CONTENT_TYPE"].should eq("x-foo-bar")
    @env["CONTENT_LENGTH"].should eq("10")
    @env["HTTP_FOO"].should eq("Bar")
  end

  it "returns the response" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    response.status.should eq(200)
    response.headers["Foo"].should eq("Bar")
    response.body.should eq("hello")
  end

  it "returns a serializable response" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    Marshal.load(Marshal.dump(response)).should eq(response)
  end

  it "can be created in a controlled environment" do
    env = { "REMOTE_ADDR" => "192.0.43.10" }
    client = HTTPSpec::Clients::Rack.new(app, env)
    client.dispatch(HTTPSpec::Request.new(:get, "/path", "", {}))
    @env["REMOTE_ADDR"].should eq("192.0.43.10")
  end
end
