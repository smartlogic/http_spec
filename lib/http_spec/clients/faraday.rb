require "http_spec/types"
require "faraday"

module HTTPSpec
  module Clients
    class Faraday
      def initialize(conn)
        @conn = conn
      end

      def dispatch(request)
        response = @conn.send(request.method, request.path) do |req|
          req.headers = request.headers || {}
          req.body = request.body
        end
        from_faraday response
      end

      private

      def from_faraday(response)
        HTTPSpec::Response.new(response.status, response.body, response.headers)
      end
    end
  end
end
