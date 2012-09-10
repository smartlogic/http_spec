require "spec_helper"
require "http_spec/dsl/methods"

describe "methods dsl" do
  include HTTPSpec::DSL::Methods

  before do
    HTTPSpec.client = FakeClient.new
  end

  it "delegates simple requests to a client" do
    [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
      response = send(method, "/path")
      response.status.should eq(200)
      response.body.should eq("response body")
      response.headers.should eq("response" => "header")
    end
  end

  it "exposes the last response" do
    [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
      send(method, "/path")
      last_response.status.should eq(200)
      last_response.body.should eq("response body")
      last_response.headers.should eq("response" => "header")
    end
  end

  it "raises if no request has been made" do
    expect { last_response }.to raise_error("No request yet.")
  end
end
