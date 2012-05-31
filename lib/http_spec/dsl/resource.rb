require "forwardable"

module DSL
  module Resource
    extend Forwardable

    def self.define_actions(*methods)
      methods.each do |method|
        define_method(method) do |*args|
          client.send(method, *args)
        end
      end
    end

    define_actions :get, :post, :put, :patch, :delete, :options, :head

    def_delegators :client, :status, :response_headers, :response_body

    alias response_status status

    def do_request
      method = example.metadata[:method]
      route = example.metadata[:route]
      request_headers = example.metadata[:request_headers]
      request_body = example.metadata[:request_body]
      send(method, route, request_body, request_headers)
    end
  end
end
