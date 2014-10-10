module HTTPSpec
  module DSL
    module Parameters
      def self.included(base)
        base.extend(ClassMethods)
        base.metadata[:parameters] = []
      end

      module ClassMethods
        def parameter(name, description, extra = {})
          param = extra.merge(:name => name, :description => description)
          copy_superclass_metadata(:parameters)
          metadata[:parameters].push(param)
        end

        def copy_superclass_metadata(key)
          return unless superclass_metadata && superclass_metadata[key]
          if superclass_metadata[key].equal?(metadata[key])
            metadata[key] = superclass_metadata[key].dup
          end
        end
      end

      def params
        return {} unless RSpec.current_example.metadata[:parameters]
        @params ||= {}
        RSpec.current_example.metadata[:parameters].each do |param|
          name = param[:name]
          @params[name] ||= send(name) if respond_to?(name)
        end
        @params
      end
    end
  end
end
