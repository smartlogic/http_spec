module HTTPSpec
  Request = Struct.new(:method, :path, :body, :headers, :parameters)
  Response = Struct.new(:status, :body, :headers)
end
