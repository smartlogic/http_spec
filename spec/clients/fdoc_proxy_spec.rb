require "spec_helper"
require "http_spec/clients/fdoc_proxy"

describe HTTPSpec::Clients::FdocProxy do
  let(:client) { HTTPSpec::Clients::FdocProxy.new(inner, "spec/fixtures/fdoc") }
  let(:inner) { stub }

  it "proxies requests to an inner application" do
    request = HTTPSpec::Request.new(:get, "/path", "", {})
    response = HTTPSpec::Response.new(200, "", {})
    inner.should_receive(:dispatch).with(request).and_return(response)
    client.dispatch(request)
  end

  it "raises an exception if the request is invalid" do
    request = HTTPSpec::Request.new(:post, "/path", '{"foo":"bar"}', {})
    expect {
      client.dispatch(request)
    }.to raise_error(JSON::Schema::ValidationError, /name/)
  end

  it "raises an exception if the response is invalid" do
    request = HTTPSpec::Request.new(:get, "/error", "", {})
    response = HTTPSpec::Response.new(200, '{}', {})
    inner.stub(:dispatch).with(request).and_return(response)
    expect {
      client.dispatch(request)
    }.to raise_error(JSON::Schema::ValidationError, /foo/)
  end
end
