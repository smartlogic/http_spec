require "spec_helper"
require "http_spec/clients/vcr_proxy"

describe HTTPSpec::Clients::VCRProxy do
  let(:client) { HTTPSpec::Clients::VCRProxy.new(inner, "cassette", dir) }
  let(:inner) do
    mock_client do |request|
      case request.path
      when hello.path then greeting
      when goodbye.path then farewell
      end
    end
  end
  let(:hello) { HTTPSpec::Request.new(:get, "/greetings", "", {}) }
  let(:goodbye) { HTTPSpec::Request.new(:get, "/farewells", "", {}) }
  let(:greeting) { HTTPSpec::Response.new(200, "Hello, World", {}) }
  let(:farewell) { HTTPSpec::Response.new(200, "Goodbye, World", {}) }
  let(:dir) { "tmp/recordings" }

  before do
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
  end

  it "proxies requests to an inner client" do
    client.dispatch(hello).should eq(greeting)
  end

  it "returns a recorded response when replayed" do
    one = HTTPSpec::Clients::VCRProxy.new(inner, "cassette", dir)
    two = HTTPSpec::Clients::VCRProxy.new(inner, "cassette", dir)
    one.dispatch(hello)
    one.dispatch(goodbye)
    inner.should_not_receive(:dispatch)
    two.dispatch(hello).should eq(greeting)
    two.dispatch(goodbye).should eq(farewell)
  end

  it "errors when the replayed requests do not match the recording" do
    one = HTTPSpec::Clients::VCRProxy.new(inner, "cassette", dir)
    two = HTTPSpec::Clients::VCRProxy.new(inner, "cassette", dir)
    one.dispatch(hello)
    expect {
      two.dispatch(goodbye)
    }.to raise_error("Request does not match recording.")
  end
end
