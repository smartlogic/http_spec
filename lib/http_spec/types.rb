module HTTPSpec
  Request = Struct.new(:method, :path, :body, :headers, :parameters) do
    def dup
      Request.new(method, path.dup, body, headers, parameters)
    end
  end

  Response = Struct.new(:status, :body, :headers)
end
