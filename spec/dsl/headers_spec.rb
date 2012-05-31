require "spec_helper"
require "http_spec/dsl/headers"

describe "headers dsl" do
  include DSL::Headers

  header "Accept", "text/html"
  header "Content-Type", "application/x-www-form-urlencoded"

  it "records declared headers in example metadata" do
    example.metadata[:request_headers].should eq({
      "Accept" => "text/html",
      "Content-Type" => "application/x-www-form-urlencoded"
    })
  end

  context "when used in nested contexts" do
    header "Content-Type", "application/xml"
    header "Content-Length", "100"

    it "inherits headers from outer contexts" do
      example.metadata[:request_headers].should eq({
        "Accept" => "text/html",
        "Content-Type" => "application/xml",
        "Content-Length" => "100"
      })
    end
  end
end
