require "spec_helper"
require "http_spec/clients/webmachine"

class FakeResource < Webmachine::Resource
  def initialize
    response.headers["Foo"] = request["Foo"]
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
    response.headers["Query"].should eq("query=string")
  end
end
