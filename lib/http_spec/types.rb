module HTTPSpec
  Request = Struct.new(:method, :path, :body, :headers) do
    def dup
      Request.new(method, path.dup, body, headers)
    end
  end

  Response = Struct.new(:status, :body, :headers)
end
