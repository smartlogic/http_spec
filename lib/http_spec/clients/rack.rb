require "rack/mock"

module Clients
  class Rack
    def initialize(app)
      @session = ::Rack::MockRequest.new(app)
    end

    def self.define_actions(*methods)
      methods.each do |method|
        define_method(method) do |path, request_body=nil, request_headers={}|
          request(method, path, request_body, request_headers)
        end
      end
    end

    define_actions :get, :post, :put, :delete, :options, :head

    def status
      @last_response.status
    end

    def response_body
      @last_response.body
    end

    def response_headers
      @last_response.headers
    end

    private

    def request(method, path, request_body, request_headers)
      opts = headers_to_env(request_headers)
      opts[:input] = request_body
      @last_response = @session.request(method, path, opts)
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
