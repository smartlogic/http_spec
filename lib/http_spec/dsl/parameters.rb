require "http_spec/dsl/metadata_helpers"

module HTTPSpec
  module DSL
    module Parameters
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        include MetadataHelpers

        def parameter(name, description, extra = {})
          copy_superclass_metadata(:parameters)
          metadata[:parameters] ||= {}
          metadata[:parameters][name] = extra.merge(:description => description)
        end
      end

      def params
        params = {}
        example.metadata[:parameters].each_key do |name|
          params[name] = send(name) if respond_to?(name)
        end
        params
      end
    end
  end
end
