require "http_spec/dsl/resource"

describe "resource dsl" do
  include DSL::Resource

  let(:client) { stub }

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
