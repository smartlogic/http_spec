require "http_spec/dsl/metadata_helpers"

module DSL
  module Headers
    include MetadataHelpers

    def header(name, value)
      copy_superclass_metadata(:request_headers)
      metadata[:request_headers] ||= {}
      metadata[:request_headers][name] = value
    end
  end
end
