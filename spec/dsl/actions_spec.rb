require "spec_helper"
require "http_spec/dsl/actions"

describe "actions dsl" do
  include DSL::Actions

  [:get, :post, :put, :patch, :delete, :options, :head].each do |method|
    send(method, "/route") do
      let(:http_method) { method.to_s.upcase }

      it "creates a context with a nice description" do
        example.example_group.description.should eq("#{http_method} /route")
      end

      it "records the method in the example metadata" do
        example.metadata[:method].should eq(method) # e.g., :get
        example.metadata[:http_method].should eq(http_method) # e.g., "GET"
      end

      it "records the route in the example metadata" do
        example.metadata[:route].should eq("/route")
      end
    end
  end
end
