module DSL
  module Actions
    def self.define_action(method)
      define_method method do |route, &block|
        http_method = method.to_s.upcase
        metadata[:http_method] = http_method
        metadata[:route] = route
        context("#{http_method} #{route}", &block)
      end
    end

    define_action :get
    define_action :post
    define_action :put
    define_action :delete
  end
end
