require 'base64'

class ApiAuthentication::HttpAuthenticationTest < MiniTest::Unit::TestCase

  include ApiAuthentication::HttpAuthentication
  include Base64

  attr_reader :request

  def test_invalid_encoding
    @request = stub('request', authorization: "\x255")

    assert_nil, http_authentication
  end

  def test_http_user_authentication
    @request = stub('request', authorization: encode_credentials('user' , 'pass').strip)

    assert_equal 'user', http_authentication
  end

  def test_http_password_authentication
    @request = stub('request', authorization: encode_credentials('', 'pass').strip)

    assert_equal 'pass', http_authentication
  end

  private

  def encode_credentials(user, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
  end
end
