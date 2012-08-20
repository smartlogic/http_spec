require "spec_helper"
require "http_spec/clients/vcr_proxy"

describe HTTPSpec::Clients::VCRProxy do
  let(:inner) { stub }
  let(:client) { HTTPSpec::Clients::VCRProxy.new(inner) }

  it "proxies requests to an inner client" do
    request = HTTPSpec::Request.new
    response = HTTPSpec::Response.new
    inner.stub(:dispatch).with(request).and_return(response)
    client.dispatch(request).should eq(response)
  end

  it "returns a recorded response on duplicate requests" do
    request = HTTPSpec::Request.new
    called = 0
    inner.stub(:dispatch) do
      called += 1
    end
    client.dispatch(request)
    client.dispatch(request)
    called.should eq(1)
  end

  it "proxies to the inner client for new requests" do
    called = 0
    inner.stub(:dispatch) do
      called += 1
    end
    client.dispatch(HTTPSpec::Request.new(:get))
    client.dispatch(HTTPSpec::Request.new(:post))
    called.should eq(2)
  end
end
