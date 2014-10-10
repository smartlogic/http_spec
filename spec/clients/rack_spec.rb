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
    expect(@env["REQUEST_METHOD"]).to eq("GET")
    expect(@env["PATH_INFO"]).to eq("/path")
  end

  it "accepts query parameters as part of the path" do
    request = HTTPSpec::Request.new(:get, "/path?query=string", "", {})
    client.dispatch(request)
    expect(@env["QUERY_STRING"]).to eq("query=string")
  end

  it "sends the response body as input" do
    request = HTTPSpec::Request.new(:post, "/path", "foobarbaz", {})
    client.dispatch(request)
    expect(@env["rack.input"].read).to eq("foobarbaz")
  end

  it "converts headers to env before requesting" do
    headers = {
      "Content-Type" => "x-foo-bar",
      "Content-Length" => "10",
      "Foo" => "Bar"
    }
    request = HTTPSpec::Request.new(:get, "/path", "", headers)
    client.dispatch(request)
    expect(@env["CONTENT_TYPE"]).to eq("x-foo-bar")
    expect(@env["CONTENT_LENGTH"]).to eq("10")
    expect(@env["HTTP_FOO"]).to eq("Bar")
  end

  it "returns the response" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    expect(response.status).to eq(200)
    expect(response.headers["Foo"]).to eq("Bar")
    expect(response.body).to eq("hello")
  end

  it "returns a serializable response" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    expect(Marshal.load(Marshal.dump(response))).to eq(response)
  end

  it "can be created in a controlled environment" do
    env = { "REMOTE_ADDR" => "192.0.43.10" }
    client = HTTPSpec::Clients::Rack.new(app, env)
    client.dispatch(HTTPSpec::Request.new(:get, "/path", "", {}))
    expect(@env["REMOTE_ADDR"]).to eq("192.0.43.10")
  end
end
