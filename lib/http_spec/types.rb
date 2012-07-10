module HTTPSpec
  Request = Struct.new(:method, :path, :body, :headers) do
    def self.from_metadata(metadata)
      method = metadata[:method]
      path = metadata[:path]
      headers = metadata[:request_headers]
      body = metadata[:request_body]
      new(method, path, body, headers)
    end
  end

  Response = Struct.new(:status, :body, :headers) do
    def to_metadata!(metadata)
      metadata[:status] = status
      metadata[:response_headers] = headers
      metadata[:response_body] = body
    end
  end
end
