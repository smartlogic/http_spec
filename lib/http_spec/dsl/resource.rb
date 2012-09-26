require "http_spec"
require "http_spec/types"
require "uri"

module HTTPSpec
  module DSL
    module Resource
      def self.included(base)
        base.extend(ClassMethods)
        base.metadata[:default_headers] = {}
      end

      module ClassMethods
        def self.define_actions(*methods)
          methods.each do |method|
            define_method(method) do |route, metadata = {}, &block|
              description = "#{method.to_s.upcase} #{route}"
              metadata[:request] = Request.new(method, route, "", {})
              context(description, metadata, &block)
            end
          end
        end

        define_actions :get, :post, :put, :patch, :delete, :options, :head

        def header(name, value)
          copy_superclass_metadata(:default_headers)
          metadata[:default_headers][name] = value
        end

        def copy_superclass_metadata(key)
          return unless superclass_metadata && superclass_metadata[key]
          if superclass_metadata[key].equal?(metadata[key])
            metadata[key] = superclass_metadata[key].dup
          end
        end
      end

      def do_request(options = {})
        request = RequestBuilder.new(self, options).build
        @last_response = HTTPSpec.dispatch(request)
      end

      def status
        @last_response.status
      end
      alias response_status status

      def response_headers
        @last_response.headers
      end

      def response_body
        @last_response.body
      end

      class RequestBuilder
        attr_reader :body

        def initialize(context, options)
          @context = context
          @options = options
          @body = options.fetch(:body, "")
          @headers = options.fetch(:headers, {})
          @query = options.fetch(:query, {})
        end

        def build
          Request.new(method, path, body, headers)
        end

        def method
          metadata[:request].method
        end

        def path
          if query.empty?
            substituted_path
          else
            "#{substituted_path}?#{query}"
          end
        end

        def headers
          metadata[:default_headers].merge(@headers)
        end

        def metadata
          @context.example.metadata
        end

        def substituted_path
          metadata[:request].path.gsub(/:(\w+)/) do |match|
            if @options.key?($1.to_sym)
              @options[$1.to_sym]
            elsif @context.respond_to?($1)
              @context.send($1)
            else
              match
            end
          end
        end

        def query
          ::URI.encode_www_form(@query)
        end
      end
    end
  end
end
