require "http_spec/types"
require "http_parser"
require "tempfile"
require "uri"

module HTTPSpec
  module Clients
    class CGI
      def initialize(executable_path, env = {})
        @executable_path = executable_path
        @env = env
      end

      def dispatch(request)
        env = Environment.new(request).to_cgi(@env)
        IO.popen([env, @executable_path], "r+") do |cgi|
          cgi.write request.body
          cgi.close_write
          from_cgi cgi.read
        end
      end

      private

      def from_cgi(cgi)
        parser = HTTP::Parser.new
        body = ""

        parser.on_body = proc { |chunk| body << chunk }

        parser << cgi

        HTTPSpec::Response.new(parser.status_code, body, parser.headers)
      end

      class Environment
        def initialize(request)
          @request = request
          @uri = URI.parse(request.path)
        end

        def to_cgi(env)
          headers_to_env(@request.headers, env.merge(
            "REQUEST_METHOD" => request_method,
            "PATH_INFO" => path_info,
            "QUERY_STRING" => query_string,
            "CONTENT_LENGTH" => content_length
          ))
        end

        def headers_to_env(headers, env)
          headers.inject(env) do |env, (k, v)|
            k = k.tr("-", "_").upcase
            k = "HTTP_#{k}" unless %w{CONTENT_TYPE CONTENT_LENGTH}.include?(k)
            env.merge(k => v)
          end
        end

        def path_info
          @uri.path
        end

        def query_string
          @uri.query.to_s
        end

        def request_method
          @request.method.upcase.to_s
        end

        def content_length
          @request.body.length.to_s
        end
      end
    end
  end
end
