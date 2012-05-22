require "http_spec/dsl/actions"
require "http_spec/dsl/parameters"
require "http_spec/dsl/headers"

module DSL
  module Resource
    include Actions
    include Parameters
    include Headers
  end
end
