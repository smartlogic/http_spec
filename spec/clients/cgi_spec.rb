require "spec_helper"
require "http_spec/clients/cgi"
require "yaml"
require "cgi"

describe HTTPSpec::Clients::CGI do
  let(:executable_path) { "spec/fixtures/cgi.rb" }
  let(:client) { HTTPSpec::Clients::CGI.new(executable_path) }

  def process(response)
    YAML.load(response.body)
  end

  it "issues requests to the app" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    data = process(response)
    data["REQUEST_METHOD"].should eq("GET")
    data["PATH_INFO"].should eq("/path")
  end

  it "accepts query parameters as part of the path" do
    request = HTTPSpec::Request.new(:get, "/path?query=string", "", {})
    response = client.dispatch(request)
    data = process(response)
    data["QUERY_STRING"].should eq("query=string")
  end

  it "sends the response body as input" do
    request = HTTPSpec::Request.new(:post, "/path", "input=foobarbaz", {})
    response = client.dispatch(request)
    data = process(response)
    data["input"].should eq(["foobarbaz"])
  end

  it "converts headers to env before requesting" do
    headers = {
      "Content-Type" => "x-foo-bar",
      "Content-Length" => "10",
      "Foo" => "Bar"
    }
    request = HTTPSpec::Request.new(:get, "/path", "", headers)
    response = client.dispatch(request)
    data = process(response)
    data["CONTENT_TYPE"].should eq("x-foo-bar")
    data["CONTENT_LENGTH"].should eq("10")
    data["HTTP_FOO"].should eq("Bar")
  end

  it "returns the response" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    response.status.should eq(200)
  end

  it "returns a serializable response" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = client.dispatch(request)
    Marshal.load(Marshal.dump(response)).should eq(response)
  end

  it "can be created in a controlled environment" do
    env = { "REMOTE_ADDR" => "192.0.43.10" }
    client = HTTPSpec::Clients::CGI.new(executable_path, env)
    response = client.dispatch(HTTPSpec::Request.new(:get, "/path", "", {}))
    data = process(response)
    data["REMOTE_ADDR"].should eq("192.0.43.10")
  end
end
