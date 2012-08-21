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
        if @recording.new?
          response = @inner.dispatch(request)
          @recording.record(request, response)
          response
        else
          @recording.play(request)
        end
      end

      class Recording
        def initialize(cassette, dir)
          filename = Digest::SHA1.hexdigest(cassette)
          @filepath = File.join(dir, filename)
        end

        def new?
          @new ||= !File.exists?(@filepath)
        end

        def record(request, response)
          cache << [request, response]
          File.open(@filepath, "w+") do |file|
            Marshal.dump(@cache, file)
          end
        end

        def play(request)
          next_request, next_response = cache.shift
          if next_request == request
            next_response
          else
            raise "Request does not match recording."
          end
        end

        def cache
          @cache ||=
            if File.exists?(@filepath)
              File.open(@filepath, "r+") do |file|
                Marshal.load(file)
              end
            else
              []
            end
        end
      end
    end
  end
end
