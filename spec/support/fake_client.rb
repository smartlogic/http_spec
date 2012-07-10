class FakeClient
  def dispatch(request)
    HTTPSpec::Response.new(200, "response body", "response" => "header")
  end
end
