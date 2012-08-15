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
end
