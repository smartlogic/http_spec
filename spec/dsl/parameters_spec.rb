require "http_spec/dsl/parameters"

describe "parameters dsl" do
  include DSL::Parameters

  parameter "name", "name of the resource", :foo => :bar
  parameter "owner", "whom is responsible for the resource"

  it "records declared parameters in example metadata" do
    example.metadata[:parameters].should eq({
      "name" => { :description => "name of the resource", :foo => :bar },
      "owner" => { :description => "whom is responsible for the resource" }
    })
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
end
