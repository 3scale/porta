# frozen_string_literal: true

module BackendHelpers
  def backend_url(path)
    "http://#{BackendClient::Connection::DEFAULT_HOST}#{path}"
  end

  def fake_status(code)
    parsed_code = code.to_i
    [parsed_code, Rack::Utils::HTTP_STATUS_CODES[parsed_code]]
  end
end
