require "spec_helper"
require "http_spec/dsl/resource"

describe "resource dsl" do
  include HTTPSpec::DSL::Resource

  let(:client) { FakeClient.new }

  [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
    send(method, "/route") do
      let(:http_method) { method.to_s.upcase }

      it "creates a context with a nice description" do
        example.example_group.description.should eq("#{http_method} /route")
      end

      it "records the method in the example metadata" do
        example.metadata[:method].should eq(method)
      end

      it "records the route in the example metadata" do
        example.metadata[:route].should eq("/route")
      end
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

  describe "parameters" do
    parameter "name", "name of the resource", :foo => :bar
    parameter "owner", "whom is responsible for the resource"

    it "records declared parameters in example metadata" do
      example.metadata[:parameters].should eq({
        "name" => { :description => "name of the resource", :foo => :bar },
        "owner" => { :description => "whom is responsible for the resource" }
      })
    end

    it "has empty params by default" do
      params.should eq({})
    end

    context "when used in nested contexts" do
      parameter "cost", "current market value of the resource"
      parameter "location", "where the resource lives"

      it "inherits parameters from outer contexts" do
        example.metadata[:parameters].should eq({
          "name" => { :description => "name of the resource", :foo => :bar },
          "owner" => { :description => "whom is responsible for the resource" },
          "cost" => { :description => "current market value of the resource" },
          "location" => { :description => "where the resource lives" }
        })
      end
    end

    context "when the example defines methods named after parameters" do
      let(:name) { "test name" }
      let(:not_a_param) { "should not appear" }

      it "indexes the parameter values in params" do
        params.should eq("name" => "test name")
      end
    end
  end
end
