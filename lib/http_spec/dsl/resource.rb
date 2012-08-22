require "http_spec"
require "http_spec/types"

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
        @last_response = HTTPSpec.dispatch(build_request(options))
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

      private

      def build_request(options)
        request = example.metadata[:request]
        path = build_path(request.path, options)
        body = options.delete(:body)
        headers = default_headers(options.delete(:headers))
        Request.new(request.method, path, body, headers)
      end

      def build_path(path, options)
        path.gsub(/:(\w+)/) do |match|
          if options.key?($1.to_sym)
            options[$1.to_sym]
          elsif respond_to?($1)
            send($1)
          else
            match
          end
        end
      end

      def default_headers(headers)
        default_headers = example.metadata[:default_headers]
        return default_headers if headers.nil?
        return headers if default_headers.nil?
        default_headers.merge(headers)
      end
    end
  end
end
