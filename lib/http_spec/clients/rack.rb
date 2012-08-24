require "http_spec/types"
require "rack/mock"

module HTTPSpec
  module Clients
    class Rack
      def initialize(app)
        @session = ::Rack::MockRequest.new(app)
      end

      def dispatch(request)
        opts = headers_to_env(request.headers)
        opts[:input] = request.body
        from_rack @session.request(request.method, request.path, opts)
      end

      private

      def from_rack(response)
        HTTPSpec::Response.new(response.status, response.body, response.headers)
      end

      def headers_to_env(headers)
        headers.inject({}) do |env, (k, v)|
          k = k.tr("-", "_").upcase
          k = "HTTP_#{k}" unless %w{CONTENT_TYPE CONTENT_LENGTH}.include?(k)
          env.merge(k => v)
        end
      end
    end
  end
end
