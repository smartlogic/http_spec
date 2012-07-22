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
              http_method = method.to_s.upcase
              metadata[:method] = method
              metadata[:route] = route
              context("#{http_method} #{route}", &block)
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

      def do_request
        example.metadata[:path] ||= build_path
        request = Request.from_metadata(example.metadata)
        response = client.dispatch(request)
        response.to_metadata!(example.metadata)
        response
      end

      def params
        params = {}
        example.metadata[:parameters].each_key do |name|
          params[name] = send(name) if respond_to?(name)
        end
        params
      end

      def status
        example.metadata[:status]
      end
      alias response_status status

      def response_headers
        example.metadata[:response_headers]
      end

      def response_body
        example.metadata[:response_body]
      end

      private

      def build_path
        return unless example.metadata[:route]
        example.metadata[:route].gsub(/:(\w+)/) do |match|
          if params.key?($1)
            params[$1]
          else
            match
          end
        end
      end
    end
  end
end
