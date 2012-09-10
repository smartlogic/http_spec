require "http_spec"
require "http_spec/types"

module HTTPSpec
  module DSL
    module Methods
      def self.define_actions(*methods)
        methods.each do |method|
          define_method(method) do |path, body="", headers={}|
            request = Request.new(method, path, body, headers)
            @last_response = HTTPSpec.dispatch(request)
          end
        end
      end

      define_actions :get, :post, :put, :patch, :delete, :options, :head

      def last_response
        @last_response or raise "No request yet."
      end
    end
  end
end
