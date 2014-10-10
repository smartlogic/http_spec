require "spec_helper"
require "http_spec/dsl/parameters"

describe "parameters dsl" do
  include HTTPSpec::DSL::Parameters

  it "has empty params by default" do
    expect(params).to eq({})
  end

  context "when parameters are defined" do
    parameter :name, "the name", :foo => :bar
    parameter :owner, "the owner"

    let(:name) { "test name" }

    it "indexes the parameter values in params" do
      expect(params).to eq(:name => "test name")
    end

    it "lets examples mutate param values" do
      params[:name] = "other name"
      expect(params[:name]).to eq("other name")
    end

    it "stores parameter information in metadata" do |example|
      expect(example.metadata[:parameters]).to eq([
        { :name => :name, :description => "the name", :foo => :bar },
        { :name => :owner, :description => "the owner" }
      ])
    end

    context "two levels deep" do
      parameter :cost, "the cost"
      parameter :location, "the location"

      it "includes parameters from outer contexts" do |example|
        expect(example.metadata[:parameters]).to eq([
          { :name => :name, :description => "the name", :foo => :bar },
          { :name => :owner, :description => "the owner" },
          { :name => :cost, :description => "the cost" },
          { :name => :location, :description => "the location" }
        ])
      end
    end
  end
end
