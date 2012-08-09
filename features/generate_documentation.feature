Feature: Generate Documentation
  Background:
    Given a file named "app.rb" with:
      """ruby
      class App
        def initialize
          @greetings = {}
        end

        def call(env)
          request = Rack::Request.new(env)
          response = Rack::Response.new
          response["Content-Type"] = "text/plain"
          case request.path_info
          when %r"^/greetings/?(.*)"
            if request.put?
              params =  JSON.parse(request.body.read)
              @greetings[$1] = params["target"]
              response.status = 201
            else
              target = @greetings.fetch($1, "World")
              response.write("Hello, #{target}!")
            end
          when "/farewells"
            response.write("Goodbye, World!")
          end
          response.finish
        end
      end
      """
    And   a file named "app_spec.rb" with:
      """ruby
      require "http_spec/dsl/resource"
      require "http_spec/dsl/methods"
      require "http_spec/dsl/parameters"
      require "http_spec/clients/raddocs_proxy"
      require "http_spec/clients/rack"

      describe "Greetings App", :explanation => "" do
        include HTTPSpec::DSL::Resource
        include HTTPSpec::DSL::Methods
        include HTTPSpec::DSL::Parameters

        let(:client) {
          HTTPSpec::Clients::RaddocsProxy.new(
            HTTPSpec::Clients::Rack.new(App.new),
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

        put "/greetings/:id", :resource_name => "Greetings" do
          parameter :target, "the entity being greeted"

          example "Publishing a greeting" do
            params[:target] = "Mars"

            do_request :id => "curiosity", :body => params.to_json
            status.should eq(201)

            check = get "/greetings/curiosity"
            check.body.should eq("Hello, Mars!")
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
      | Being greeted         |
      | Publishing a greeting |
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

  Scenario: Viewing an example with parameters
    When  I load Raddocs
    And   I view documentation for "Publishing a greeting"
    Then  the parameters should be:
      | target | the entity being greeted |
