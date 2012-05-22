require "http_spec/dsl/resource"

describe "resources dsl" do
  extend DSL::Resource

  describe "parameters" do
    parameter "name", "name of the resource"
    parameter "owner", "whom is responsible for the resource"

    it "should be recorded in example metadata" do
      example.metadata[:parameters].should eq({
        "name" => { :description => "name of the resource" },
        "owner" => { :description => "whom is responsible for the resource" }
      })
    end

    context "defined in nested context" do
      parameter "cost", "current market value of the resource"
      parameter "location", "where the resource lives"

      it "should be added to the outer contexts' parameters" do
        example.metadata[:parameters].should eq({
          "name" => { :description => "name of the resource" },
          "owner" => { :description => "whom is responsible for the resource" },
          "cost" => { :description => "current market value of the resource" },
          "location" => { :description => "where the resource lives" }
        })
      end
    end
  end

  describe "parameter metadata" do
    parameter "name", "name of the resource", :foo => :bar

    it "should be recorded in the example metadata" do
      example.metadata[:parameters].should eq({
        "name" => { :description => "name of the resource", :foo => :bar }
      })
    end
  end

  describe "request headers" do
    header "Accept", "text/html"
    header "Content-Type", "application/x-www-form-urlencoded"

    it "should be recorded in the example metadata" do
      example.metadata[:request_headers].should eq({
        "Accept" => "text/html",
        "Content-Type" => "application/x-www-form-urlencoded"
      })
    end

    context "defined in nested context" do
      header "Content-Type", "application/xml"
      header "Content-Length", "100"

      it "should be added to the outer context's headers" do
        example.metadata[:request_headers].should eq({
          "Accept" => "text/html",
          "Content-Type" => "application/xml",
          "Content-Length" => "100"
        })
      end
    end
  end

  [:get, :post, :put, :delete].each do |method|
    http_method = method.to_s.upcase

    send(method, "/route") do
      it "should create a context with a nice description" do
        example.example_group.description.should eq("#{http_method} /route")
      end

      it "should record the http method in the example metadata" do
        example.metadata[:http_method].should eq(http_method)
      end

      it "should record the route in the example metadata" do
        example.metadata[:route].should eq("/route")
      end
    end
  end
end
