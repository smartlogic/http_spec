require "http_spec/dsl/metadata_helpers"

module DSL
  module Parameters
    include MetadataHelpers

    def parameter(name, description, extra = {})
      copy_superclass_metadata(:parameters)
      metadata[:parameters] ||= {}
      metadata[:parameters][name] = extra.merge(:description => description)
    end
  end
end
