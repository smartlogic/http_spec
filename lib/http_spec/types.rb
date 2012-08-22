require "values"

module HTTPSpec
  Request = Value.new(:method, :path, :body, :headers)
  Response = Value.new(:status, :body, :headers)
end
