module HTTPSpec
  class << self
    attr_accessor :client

    def dispatch(request)
      client.dispatch(request)
    end
  end
end
