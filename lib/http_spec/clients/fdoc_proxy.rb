require "http_spec/types"
require "fdoc"

module HTTPSpec
  module Clients
    class FdocProxy
      def initialize(inner, service_path = Fdoc.service_path)
        @inner = inner
        @service = Fdoc::Service.new(service_path)
      end

      def dispatch(request)
        endpoint = @service.open(request.method, request.path)
        endpoint.consume_request(request.body)
        response = @inner.dispatch(request)
        endpoint.consume_response(response.body, response.status)
        response
      end
    end
  end
end
