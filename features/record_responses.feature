Feature: Record Responses
  Background:
    Given a file named "app.rb" with:
      """ruby
      App = lambda do |env|
        sleep 0.1
        [200, {}, "Hello, World!"]
      end
      """
    And   a file named "app_spec.rb" with:
      """ruby
      require "http_spec/dsl/methods"
      require "http_spec/clients/vcr_proxy"
      require "http_spec/clients/rack"

      describe "Slow App" do
        include HTTPSpec::DSL::Methods

        before do
          HTTPSpec.client = HTTPSpec::Clients::VCRProxy.new(
            HTTPSpec::Clients::Rack.new(App),
            example.full_description
          )
        end

        it "says hello" do
          response = get "/"
          response.body.should eq("Hello, World!")
        end
      end
      """
    And   a directory named "recordings"

  Scenario: Recorded responses are very fast
    When  I successfully run `rspec app_spec.rb --require ./app.rb`
    And   I successfully run `rspec app_spec.rb --require ./app.rb`
    Then  the first run should take about 0.1 seconds
    And   the second run should be much faster
