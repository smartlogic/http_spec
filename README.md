[![Travis status](https://secure.travis-ci.org/smartlogic/http_spec.png)](https://secure.travis-ci.org/smartlogic/http_spec)
[![Gemnasium status](https://gemnasium.com/smartlogic/http_spec.png)](https://gemnasium.com/smartlogic/http_spec)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/smartlogic/http_spec)

# HTTPSpec

RSpec DSLs for describing API behaviors

## Features

* Supports Rack, Webmachine, and live applications (via Faraday) using pluggable client back-ends.
* Generate documentation from requests with Raddocs.
* Validate requests and responses against a schema with Fdoc.
* Record and play back responses to speed-up tests against live applications. (like VCR)

## Example Usage

```ruby
require "http_spec/dsl/resource"
require "http_spec/clients/rack"

app = lambda { |env| [200, { "Foo" => "Bar" }, ["Hello, World!"]] }
HTTPSpec.client = HTTPSpec::Clients::Rack.new(app)

describe "My Awesome App" do
  include HTTPSpec::DSL::Resource

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

Want something more light-weight?

```ruby
require "http_spec/dsl/methods"
require "http_spec/clients/rack"

app = lambda { |env| [200, { "Foo" => "Bar" }, ["Hello, World!"]] }
HTTPSpec.client = HTTPSpec::Clients::Rack.new(app)

describe "My Awesome App" do
  include HTTPSpec::DSL::Methods

  it "should be successful" do
    get("/foo").status.should eq(200)
  end

  it "should tell us about foo" do
    get("/bar").headers["Foo"].should eq("Bar")
  end

  it "should greet us" do
    get("/baz").body.should eq("Hello, World!")
  end
end
```
