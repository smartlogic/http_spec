Feature: Record Responses
  Background:
    Given a file named "app.rb" with:
      """ruby
      class App
        def initialize
          @count = 0
        end

        def call(env)
          case env["PATH_INFO"]
          when "/wait"
            sleep 1
            [200, {}, "Hello, World!"]
          when "/count"
            @count += 1
            [200, {}, [@count]]
          end
        end
      end
      """
    And   a directory named "recordings"

  Scenario: Recorded responses are very fast
    Given a file named "app_spec.rb" with:
      """ruby
      require "http_spec/dsl/methods"
      require "http_spec/clients/vcr_proxy"
      require "http_spec/clients/rack"

      describe "Slow App" do
        include HTTPSpec::DSL::Methods

        before do
          HTTPSpec.client = HTTPSpec::Clients::VCRProxy.new(
            HTTPSpec::Clients::Rack.new(App.new),
            example.full_description
          )
        end

        it "says hello" do
          response = get "/wait"
          response.body.should eq("Hello, World!")
        end
      end
      """
    When  I successfully run `rspec app_spec.rb --require ./app.rb`
    And   I successfully run `rspec app_spec.rb --require ./app.rb`
    Then  the second run should be about 1 second faster than the first

  Scenario: Requests are recorded in the correct order
    Given a file named "app_spec.rb" with:
      """ruby
      require "http_spec/dsl/methods"
      require "http_spec/clients/vcr_proxy"
      require "http_spec/clients/rack"

      describe "Counting App" do
        include HTTPSpec::DSL::Methods

        before do
          HTTPSpec.client = HTTPSpec::Clients::VCRProxy.new(
            HTTPSpec::Clients::Rack.new(App.new),
            example.full_description
          )
        end

        it "maintains a count" do
          get("/count").body.should eq("1")
          get("/count").body.should eq("2")
        end
      end
      """
    When  I successfully run `rspec app_spec.rb --require ./app.rb`
    And   I run `rspec app_spec.rb --require ./app.rb`
    Then  the exit status should be 0
