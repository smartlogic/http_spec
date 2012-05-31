module DSL
  module Actions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def self.define_actions(*methods)
        methods.each do |method|
          define_method(method) do |route, &block|
            http_method = method.to_s.upcase
            metadata[:method] = method
            metadata[:http_method] = http_method
            metadata[:route] = route
            context("#{http_method} #{route}", &block)
          end
        end
      end

      define_actions :get, :post, :put, :patch, :delete, :options, :head
    end
  end
end
