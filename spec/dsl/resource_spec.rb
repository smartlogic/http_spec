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

      it "creates a context with a nice description" do |example|
        description = example.example_group.description
        expect(description).to eq("#{http_method} /:foo/:id")
      end

      it "forwards the request to the client" do
        expect(client).to receive(:dispatch) do |request|
          expect(request.method).to eq(method)
          expect(request.path).to eq("/:foo/:id")
          expect(request.body).to eq("body")
          expect(request.headers).to eq("foo" => "bar")
        end
        do_request :body => "body", :headers => { "foo" => "bar" }
      end

      it "exposes response information" do
        do_request
        expect(status).to eq(200)
        expect(response_headers).to eq("response" => "header")
        expect(response_body).to eq("response body")
      end

      it "aliases status as response_status" do
        do_request
        expect(response_status).to eq(200)
      end

      it "substitutes values in the route" do
        expect(client).to receive(:dispatch) do |request|
          expect(request.path).to eq("/:foo/1")
        end
        do_request :id => 1
      end

      context "when route parameters are defined in the context" do
        let(:id) { 1 }

        it "substitutes the value in the route" do
          expect(client).to receive(:dispatch) do |request|
            expect(request.path).to eq("/:foo/1")
          end
          do_request
        end

        it "prefers passed-in values for substitution" do
          expect(client).to receive(:dispatch) do |request|
            expect(request.path).to eq("/:foo/2")
          end
          do_request :id => 2
        end
      end

      context "when headers are defined" do
        header "Accept", "text/html"
        header "Content-Type", "application/x-www-form-urlencoded"

        it "dispatches the headers to the client" do
          expect(client).to receive(:dispatch) do |request|
            expect(request.headers).to eq({
              "Accept" => "text/html",
              "Content-Type" => "application/x-www-form-urlencoded"
            })
          end
          do_request
        end

        it "combines group-level headers with example-level ones" do
          expect(client).to receive(:dispatch) do |request|
            expect(request.headers).to eq({
              "Accept" => "text/html",
              "Content-Type" => "application/x-www-form-urlencoded",
              "Content-Length" => "100"
            })
          end
          do_request :headers => { "Content-Length" => "100" }
        end

        it "doesn't modify the group-level headers" do
          headers = []
          allow(client).to receive(:dispatch) do |request|
            headers << request.headers["Accept"]
          end

          do_request :headers => { "Accept" => "text/plain" }
          do_request

          expect(headers).to eq(["text/plain", "text/html"])
        end

        context "two levels deep" do
          header "Content-Type", "application/xml"
          header "Content-Length", "100"

          it "includes headers from outer contexts" do
            expect(client).to receive(:dispatch) do |request|
              expect(request.headers).to eq({
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
