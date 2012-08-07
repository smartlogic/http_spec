Feature: Generate Documentation
  Background:
    Given a file named "app.rb" with:
      """ruby
      App = lambda do |env|
        response = Rack::Response.new
        response["Content-Type"] = "text/plain"
        case env["PATH_INFO"]
        when "/greetings"
          response.write("Hello, World!")
        when "/farewells"
          response.write("Goodbye, World!")
        end
        response.finish
      end
      """
    And   a file named "app_spec.rb" with:
      """ruby
      require "http_spec/dsl/resource"
      require "http_spec/clients/raddocs_proxy"
      require "http_spec/clients/rack"

      describe "Greetings App", :parameters => [], :explanation => "" do
        include HTTPSpec::DSL::Resource

        let(:client) {
          HTTPSpec::Clients::RaddocsProxy.new(
            HTTPSpec::Clients::Rack.new(App),
            example.metadata
          )
        }

        get "/greetings", :resource_name => "Greetings" do
          example "Being greeted" do
            do_request
            status.should eq(200)
            response_body.should eq("Hello, World!")
          end
        end

        get "/farewells", :resource_name => "Farewells" do
          example "Being bid farewell" do
            do_request
            status.should eq(200)
            response_body.should eq("Goodbye, World!")
          end
        end
      end
      """
    And   a directory named "docs"
    And   I successfully run `rspec app_spec.rb --require ./app.rb`

  Scenario: Viewing index
    When  I load Raddocs
    Then  the following Greetings examples should be listed:
      | Being greeted |
    And   the following Farewells examples should be listed:
      | Being bid farewell |

  Scenario: Viewing an example
    When  I load Raddocs
    And   I view documentation for "Being greeted"
    Then  the request route should be "GET /greetings"
    And   the response status should be 200
    And   the response headers should be:
      | Content-Type   | text/plain |
      | Content-Length | 13         |
    And   the response body should be "Hello, World!"
