require "spec_helper"
require "http_spec/dsl/resource"

describe "resource dsl" do
  include HTTPSpec::DSL::Resource

  let(:client) { stub }

  before do
    client.stub!(:status)
    client.stub!(:response_headers)
    client.stub!(:response_body)
  end

  it "delegates simple requests to a client" do
    [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
      client.should_receive(method).
        with("/route", "request body", "Header" => "value")
      send(method, "/route", "request body", "Header" => "value")
    end
  end

  it "makes client requests based on metadata",
    :method => :get,
    :route => "/route",
    :request_body => "request body",
    :request_headers => { "Header" => "value" } do
    client.should_receive(:get).
      with("/route", "request body", "Header" => "value")
    do_request
  end

  it "records the request information as metadata" do
    client.stub!(:get)
    get("/route", "request body", "Header" => "value")
    example.metadata[:method].should eq(:get)
    example.metadata[:route].should eq("/route")
    example.metadata[:request_body].should eq("request body")
    example.metadata[:request_headers].should eq("Header" => "value")
  end

  it "records the response information as metadata" do
    client.stub!(:get)
    client.stub!(:status).and_return(200)
    client.stub!(:response_headers).and_return("Header" => "value")
    client.stub!(:response_body).and_return("response body")
    get("/route")
    example.metadata[:status].should eq(200)
    example.metadata[:response_headers].should eq("Header" => "value")
    example.metadata[:response_body].should eq("response body")
  end

  it "delegates response methods to the client" do
    [:status, :response_headers, :response_body].each do |method|
      client.stub!(method).and_return("value")
      send(method).should eq("value")
    end
  end

  it "aliases status as response_status" do
    client.stub!(:status).and_return("value")
    response_status.should eq("value")
  end
end
