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
      expect(response.status).to eq(200)
      expect(response.body).to eq("response body")
      expect(response.headers).to eq("response" => "header")
    end
  end

  it "exposes the last response" do
    [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
      send(method, "/path")
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("response body")
      expect(last_response.headers).to eq("response" => "header")
    end
  end

  it "raises if no request has been made" do
    expect { last_response }.to raise_error("No request yet.")
  end
end
