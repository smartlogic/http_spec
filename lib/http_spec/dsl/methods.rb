require "http_spec/types"

module HTTPSpec
  module DSL
    module Methods
      def self.define_actions(*methods)
        methods.each do |method|
          define_method(method) do |path, body=nil, headers=nil|
            request = Request.new(method, path, body, headers)
            client.dispatch(request)
          end
        end
      end

      define_actions :get, :post, :put, :patch, :delete, :options, :head
    end
  end
end
