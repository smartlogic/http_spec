require "http_spec/dsl/metadata_helpers"

module HTTPSpec
  module DSL
    module Headers
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        include MetadataHelpers

        def header(name, value)
          copy_superclass_metadata(:request_headers)
          metadata[:request_headers] ||= {}
          metadata[:request_headers][name] = value
        end
      end
    end
  end
end
