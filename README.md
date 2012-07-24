# HTTPSpec

RSpec DSL for describing API behaviors

## Example Usage

```ruby
require "http_spec/dsl/resource"
require "http_spec/clients/rack"

describe "My Awesome App" do
  include HTTPSpec::DSL::Resource

  let(:client) { HTTPSpec::Clients::Rack.new(app) }
  let(:app) { lambda { |env| [200, { "Foo" => "Bar" }, ["Hello, World!"]] } }

  get "/foobar" do
    it "should be successful" do
      do_request
      status.should eq(200)
    end

    it "should tell us about foo" do
      do_request
      response_headers["Foo"].should eq("Bar")
    end

    it "should greet us" do
      do_request
      response_body.should eq("Hello, World!")
    end
  end
end
```
