require "spec_helper"
require "http_spec/dsl/resource"

describe "resource dsl" do
  include HTTPSpec::DSL::Resource

  let(:client) { FakeClient.new }

  before do
    HTTPSpec.client = client
  end

  [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
    send(method, "/:foo/:id") do
      let(:http_method) { method.to_s.upcase }

      it "creates a context with a nice description" do
        example.example_group.description.should eq("#{http_method} /:foo/:id")
      end

      it "forwards the request to the client" do
        client.should_receive(:dispatch) do |request|
          request.method.should eq(method)
          request.path.should eq("/:foo/:id")
          request.body.should eq("body")
          request.headers.should eq("foo" => "bar")
        end
        do_request :body => "body", :headers => { "foo" => "bar" }
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

      it "substitutes values in the route" do
        client.should_receive(:dispatch) do |request|
          request.path.should eq("/:foo/1")
        end
        do_request :id => 1
      end

      context "when route parameters are defined in the context" do
        let(:id) { 1 }

        it "substitutes the value in the route" do
          client.should_receive(:dispatch) do |request|
            request.path.should eq("/:foo/1")
          end
          do_request
        end

        it "prefers passed-in values for substitution" do
          client.should_receive(:dispatch) do |request|
            request.path.should eq("/:foo/2")
          end
          do_request :id => 2
        end
      end

      context "when headers are defined" do
        header "Accept", "text/html"
        header "Content-Type", "application/x-www-form-urlencoded"

        it "dispatches the headers to the client" do
          client.should_receive(:dispatch) do |request|
            request.headers.should eq({
              "Accept" => "text/html",
              "Content-Type" => "application/x-www-form-urlencoded"
            })
          end
          do_request
        end

        it "combines group-level headers with example-level ones" do
          client.should_receive(:dispatch) do |request|
            request.headers.should eq({
              "Accept" => "text/html",
              "Content-Type" => "application/x-www-form-urlencoded",
              "Content-Length" => "100"
            })
          end
          do_request :headers => { "Content-Length" => "100" }
        end

        context "two levels deep" do
          header "Content-Type", "application/xml"
          header "Content-Length", "100"

          it "includes headers from outer contexts" do
            client.should_receive(:dispatch) do |request|
              request.headers.should eq({
                "Accept" => "text/html",
                "Content-Type" => "application/xml",
                "Content-Length" => "100"
              })
            end
            do_request
          end
        end
      end
    end
  end
end
