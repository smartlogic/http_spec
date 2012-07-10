require "spec_helper"
require "http_spec/dsl/resource"

class FakeClient
  def dispatch(request)
    HTTPSpec::Response.new(200, "response body", "response" => "header")
  end
end

describe "resource dsl" do
  include HTTPSpec::DSL::Resource

  let(:client) { FakeClient.new }

  it "delegates simple requests to a client" do
    [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
      response = send(method, "/path")
      response.status.should eq(200)
      response.body.should eq("response body")
      response.headers.should eq("response" => "header")
    end
  end

  it "makes client requests based on metadata",
    :method => :get,
    :path => "/path",
    :request_body => "request body",
    :request_headers => { "request" => "header" } do
    client.should_receive(:dispatch) do |request|
      request.method.should eq(:get)
      request.path.should eq("/path")
      request.body.should eq("request body")
      request.headers.should eq("request" => "header")
      HTTPSpec::Response.new
    end
    do_request
  end

  it "uses route metadata to construct paths", :route => "/route" do
    do_request
    example.metadata[:path].should eq("/route")
  end

  it "records the response information as metadata" do
    do_request
    example.metadata[:status].should eq(200)
    example.metadata[:response_headers].should eq("response" => "header")
    example.metadata[:response_body].should eq("response body")
  end

  it "exposes response information" do
    do_request
    status.should eq(200)
    response_headers.should eq("response" => "header")
    response_body.should eq("response body")
  end

  it "aliases status as response_status" do
    do_request
    response_status.should eq(200)
  end

  context "when params are defined" do
    let(:params) {{ "id" => "1" }}

    it "combines route metadata and params to create a path",
      :route => "/widget/:foo/:id" do
      client.should_receive(:dispatch) do |request|
        request.path.should eq("/widget/:foo/1")
        HTTPSpec::Response.new
      end
      do_request
    end
  end
end
