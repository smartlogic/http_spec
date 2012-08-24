require "http_spec"
require "http_spec/types"

module HTTPSpec
  module DSL
    module Methods
      def self.define_actions(*methods)
        methods.each do |method|
          define_method(method) do |path, body="", headers={}|
            request = Request.new(method, path, body, headers)
            HTTPSpec.dispatch(request)
          end
        end
      end

      define_actions :get, :post, :put, :patch, :delete, :options, :head
    end
  end
end
