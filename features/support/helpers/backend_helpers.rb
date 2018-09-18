module BackendHelpers
  def backend_url(path)
    "http://#{BackendClient::Connection::DEFAULT_HOST}#{path}"
  end

  def fake_status(code)
    [code.to_i, Rack::Utils::HTTP_STATUS_CODES[code.to_i]]
  end
end
