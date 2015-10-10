require "spec_helper"
require "http_spec/clients/webmachine"

class FakeResource < Webmachine::Resource
  def initialize
    response.headers["Host"] = request["Host"]
    response.headers["Query"] = request.uri.query
  end

  def content_types_provided
    [["text/plain", :to_text]]
  end

  def to_text
    request.body
  end
end

describe HTTPSpec::Clients::Webmachine do
  def app
    Webmachine::Application.new do |app|
      app.routes do
        add ["path"], FakeResource
      end
    end
  end

  let(:client) { HTTPSpec::Clients::Webmachine.new(app) }
  let(:headers) {{ "Host" => "localhost" }}

  it "issues requests to the app" do
    request = HTTPSpec::Request.new(:get, "/path", "", headers)
    response = client.dispatch(request)
    expect(response.status).to eq(200)
  end

  it "passes through the request body" do
    request = HTTPSpec::Request.new(:get, "/path", "hello", headers)
    response = client.dispatch(request)
    expect(response.body).to eq("hello")
  end

  it "passes through the request headers" do
    request = HTTPSpec::Request.new(:get, "/path", "", headers)
    response = client.dispatch(request)
    expect(response.headers["Host"]).to eq("localhost")
  end

  it "accepts query parameters as part of the path" do
    request = HTTPSpec::Request.new(:get, "/path?query=string", "", headers)
    response = client.dispatch(request)
    expect(response.headers["Query"]).to eq("query=string")
  end

  it "returns a serializable response" do
    request = HTTPSpec::Request.new(:get, "/path", "", headers)
    response = client.dispatch(request)
    expect(Marshal.load(Marshal.dump(response))).to eq(response)
  end
end
