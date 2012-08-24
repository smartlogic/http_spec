require "http_spec/types"
require "webmachine"

module HTTPSpec
  module Clients
    class Webmachine
      def initialize(app)
        @dispatcher = app.dispatcher
      end

      def dispatch(request)
        response = ::Webmachine::Response.new
        @dispatcher.dispatch(to_webmachine(request), response)
        from_webmachine response
      end

      private

      def to_webmachine(request)
        ::Webmachine::Request.new(
          request.method.to_s.upcase,
          URI.parse(request.path),
          request.headers,
          request.body
        )
      end

      def from_webmachine(response)
        Response.new(response.code, response.body, response.headers)
      end
    end
  end
end
