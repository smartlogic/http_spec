require "http_spec/types"
require "faraday"

module HTTPSpec
  module Clients
    class Faraday
      def initialize(conn)
        @conn = conn
      end

      def dispatch(request)
        @conn.send(request.method, request.path) do |req|
          req.headers = request.headers || {}
          req.body = request.body
        end
      end
    end
  end
end
