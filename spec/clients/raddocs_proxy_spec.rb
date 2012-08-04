require "spec_helper"
require "http_spec/clients/raddocs_proxy"
require "fakefs/spec_helpers"

describe HTTPSpec::Clients::RaddocsProxy do
  include FakeFS::SpecHelpers

  let(:inner) { FakeClient.new }
  let(:request) { HTTPSpec::Request.new(:get, "/path", "request body") }

  before do
    FileUtils.mkdir("docs")
  end

  it "proxies requests to an inner client" do
    client = HTTPSpec::Clients::RaddocsProxy.new(inner,
                                                 :resource_name => "foo",
                                                 :description => "bar")
    response = HTTPSpec::Response.new
    inner.should_receive(:dispatch).with(request).and_return(response)
    client.dispatch(request)
  end

  it "creates an index file" do
    a = HTTPSpec::Clients::RaddocsProxy.new(inner,
                                            :resource_name => "foo",
                                            :description => "bar")
    b = HTTPSpec::Clients::RaddocsProxy.new(inner,
                                            :resource_name => "foo",
                                            :description => "thud")
    c = HTTPSpec::Clients::RaddocsProxy.new(inner,
                                            :resource_name => "baz",
                                            :description => "quux")
    a.dispatch(request)
    b.dispatch(request)
    c.dispatch(request)
    File.open("docs/index.json", "r") do |file|
      index = JSON.load(file)
      index.should eq(
        "resources" => [
          {
            "name" => "foo", "examples" => [
              { "description" => "bar", "link" => "foo/bar.json" },
              { "description" => "thud", "link" => "foo/thud.json" }
            ]
          },
          {
            "name" => "baz", "examples" => [
              { "description" => "quux", "link" => "baz/quux.json" },
            ]
          }
        ]
      )
    end
  end

  it "creates an example file" do
    client = HTTPSpec::Clients::RaddocsProxy.new(inner,
                                                 :resource_name => "foo",
                                                 :description => "bar")
    foo = HTTPSpec::Request.new(:get, "/foo", "bar", "foo" => "bar")
    baz = HTTPSpec::Request.new(:post, "/baz", "quux")
    client.dispatch(foo)
    client.dispatch(baz)
    File.open("docs/foo/bar.json", "r") do |file|
      index = JSON.load(file)
      index.should eq(
        "resource" => "foo",
        "description" => "bar",
        "explanation" => nil,
        "parameters" => nil,
        "requests" => [
          {
            "request_headers" => { "foo" => "bar" },
            "request_method" => "GET",
            "request_path" => "/foo",
            "request_body" => "bar",
            "response_status" => 200,
            "response_headers" => { "response" => "header" },
            "response_body" => "response body"
          },
          {
            "request_headers" => {},
            "request_method" => "POST",
            "request_path" => "/baz",
            "request_body" => "quux",
            "response_status" => 200,
            "response_headers" => { "response" => "header" },
            "response_body" => "response body"
          }
        ]
      )
    end
  end
end
