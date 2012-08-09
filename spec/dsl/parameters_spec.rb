require "spec_helper"
require "http_spec/dsl/parameters"

describe "parameters dsl" do
  include HTTPSpec::DSL::Parameters

  it "has empty params by default" do
    params.should eq({})
  end

  context "when parameters are defined" do
    parameter :name, "the name", :foo => :bar
    parameter :owner, "the owner"

    let(:name) { "test name" }

    it "indexes the parameter values in params" do
      params.should eq(:name => "test name")
    end

    it "lets examples mutate param values" do
      params[:name] = "other name"
      params[:name].should eq("other name")
    end

    it "stores parameter information in metadata" do
      example.metadata[:parameters].should eq([
        { :name => :name, :description => "the name", :foo => :bar },
        { :name => :owner, :description => "the owner" }
      ])
    end

    context "two levels deep" do
      parameter :cost, "the cost"
      parameter :location, "the location"

      it "includes parameters from outer contexts" do
        example.metadata[:parameters].should eq([
          { :name => :name, :description => "the name", :foo => :bar },
          { :name => :owner, :description => "the owner" },
          { :name => :cost, :description => "the cost" },
          { :name => :location, :description => "the location" }
        ])
      end
    end
  end
end
