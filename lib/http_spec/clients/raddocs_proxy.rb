require "http_spec/types"
require "raddocs"
require "fileutils"

module HTTPSpec
  module Clients
    class RaddocsProxy
      def initialize(inner, metadata, dir = Raddocs.configuration.docs_dir)
        @inner = inner
        @resource_name = metadata.fetch(:resource_name)
        @description = metadata[:description]
        raise KeyError, "key not found :description" unless @description
        @parameters = metadata[:parameters]
        @explanation = metadata[:explanation]
        @dir = dir
      end

      def dispatch(request)
        write_index
        response = @inner.dispatch(request)
        write_example(request, response)
        response
      end

      private

      def write_index
        filepath = File.join(@dir, "index.json")
        index = load_or_new(Index, filepath)
        index.add_example(@resource_name, @description, example_path)
        File.open(filepath, "w") { |file| index.dump(file) }
      end

      def write_example(request, response)
        filepath = File.join(@dir, example_path)
        FileUtils.mkdir_p(File.dirname(filepath))
        example = load_or_new(Example, filepath, @resource_name, @description)
        example.explanation = @explanation
        example.parameters = @parameters
        example.add_request(request, response)
        File.open(filepath, "w") { |file| example.dump(file) }
      end

      def example_path
        dirname = @resource_name.gsub(/\s+/, '_').gsub(/\W/, '')
        filename = @description.downcase.gsub(/\s+/, '_').gsub(/\W/, '')
        File.join(dirname, filename + ".json")
      end

      def load_or_new(klass, filepath, *args)
        if File.exists?(filepath)
          File.open(filepath, "r") { |file| klass.load(file) }
        else
          klass.new(*args)
        end
      end

      class Index
        attr_reader :resources

        def initialize(resources = [])
          @resources = resources
        end

        def self.load(io, serializer = JSON)
          content = serializer.load(io)
          resources = content.fetch("resources")
          new(resources)
        end

        def dump(io, serializer = JSON)
          content = { "resources" => resources }
          serializer.dump(content, io)
        end

        def add_example(resource_name, description, link)
          resource = resources.find { |r| r["name"] == resource_name }
          unless resource
            resource = { "name" => resource_name, "examples" => [] }
            resources.push(resource)
          end
          examples = resource.fetch("examples")
          example = examples.find { |e| e["description"] == description }
          unless example
            example = { "description" => description, "link" => link }
            examples.push(example)
          end
        end
      end

      class Example
        attr_reader :resource_name, :description, :requests
        attr_accessor :explanation, :parameters

        def initialize(resource_name, description, requests = [])
          @resource_name = resource_name
          @description = description
          @requests = requests
        end

        def self.load(io, serializer = JSON)
          content = serializer.load(io)
          resource_name = content.fetch("resource")
          description = content.fetch("description")
          requests = content.fetch("requests")
          new(resource_name, description, requests).tap do |example|
            example.explanation = content["explanation"]
            example.parameters = content["parameters"]
          end
        end

        def dump(io, serializer = JSON)
          content = {
            "resource" => resource_name,
            "description" => description,
            "explanation" => explanation,
            "parameters" => parameters,
            "requests" => requests
          }
          serializer.dump(content, io)
        end

        def add_request(request, response)
          requests.push(
            "request_headers" => request.headers,
            "request_method" => request.method.upcase,
            "request_path" => request.path,
            "request_body" => request.body,
            "response_status" => response.status,
            "response_headers" => response.headers,
            "response_body" => response.body
          )
        end
      end
    end
  end
end
