require "http_spec/types"

module HTTPSpec
  module DSL
    module Resource
      def do_request
        example.metadata[:path] ||= build_path
        request = Request.from_metadata(example.metadata)
        response = client.dispatch(request)
        response.to_metadata!(example.metadata)
        response
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
