require "http_spec/types"
require "digest/sha1"

module HTTPSpec
  module Clients
    class VCRProxy
      def initialize(inner, cassette, dir = "recordings")
        @inner = inner
        @recording = Recording.new(cassette, dir)
      end

      def dispatch(request)
        @recording[request] ||= @inner.dispatch(request)
      end

      class Recording
        def initialize(cassette, dir)
          filename = Digest::SHA1.hexdigest(cassette)
          @filepath = File.join(dir, filename)
        end

        def [](request)
          cache[request]
        end

        def []=(request, response)
          cache[request] = response
          File.open(@filepath, "w+") do |file|
            Marshal.dump(@cache, file)
          end
        end

        def cache
          @cache ||=
            if File.exists?(@filepath)
              File.open(@filepath, "r+") do |file|
                Marshal.load(file)
              end
            else
              {}
            end
        end
      end
    end
  end
end
