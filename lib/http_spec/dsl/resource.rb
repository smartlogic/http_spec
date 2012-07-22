require "http_spec/types"
require "http_spec/dsl/metadata_helpers"

module HTTPSpec
  module DSL
    module Resource
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        include MetadataHelpers

        def self.define_actions(*methods)
          methods.each do |method|
            define_method(method) do |route, &block|
              description = "#{method.to_s.upcase} #{route}"
              request = Request.new(method, route)
              context(description, :request => request, &block)
            end
          end
        end

        define_actions :get, :post, :put, :patch, :delete, :options, :head

        def parameter(name, description, extra = {})
          copy_superclass_metadata(:parameters)
          metadata[:parameters] ||= {}
          metadata[:parameters][name] = extra.merge(:description => description)
        end
      end

      def do_request(options = {})
        request = example.metadata[:request]
        build_path(request)
        request.body = options[:body]
        request.headers = options[:headers]
        request.parameters = example.metadata[:parameters]
        @last_response = client.dispatch(request)
      end

      def params
        return {} unless example.metadata[:parameters]
        params = {}
        example.metadata[:parameters].each_key do |name|
          params[name] = send(name) if respond_to?(name)
        end
        params
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

      def build_path(request)
        request.path.gsub!(/:(\w+)/) do |match|
          if respond_to?($1)
            send($1)
          else
            match
          end
        end
      end
    end
  end
end
