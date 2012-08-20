require "http_spec/types"

module HTTPSpec
  module Clients
    class VCRProxy
      def initialize(inner)
        @inner = inner
        @cache = {}
      end

      def dispatch(request)
        @cache[request] ||= @inner.dispatch(request)
      end
    end
  end
end
