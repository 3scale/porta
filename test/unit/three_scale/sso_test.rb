require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ThreeScale::SsoTest < ActiveSupport::TestCase

  test "encrypting and decrypting data" do
    key = ThreeScale::SSO.generate_sso_key

    coder = ThreeScale::SSO::Encryptor.new key
    token = coder.encrypt_token "user-id", "buyer-id"

    decoder = ThreeScale::SSO::Encryptor.new key
    data = decoder.decrypt_token token

    assert data.include?("user-id")
  end

  test "fail to decrypt with wrong key" do
    coder = ThreeScale::SSO::Encryptor.new ThreeScale::SSO.generate_sso_key
    token = coder.encrypt_token "user-id", "buyer-id", "provider-api-key", "http://example.com"

    decoder = ThreeScale::SSO::Encryptor.new ThreeScale::SSO.generate_sso_key

    assert_raise ActiveSupport::MessageVerifier::InvalidSignature do
      decoder.decrypt_token token
    end
  end

  test "expired token" do
    coder = ThreeScale::SSO::Encryptor.new ThreeScale::SSO.generate_sso_key
    token = coder.encrypt_token "user_id"

    Timecop.travel(15.minutes.from_now) do
      assert_raise(ThreeScale::SSO::ValidationError) { coder.extract! token }
    end
  end

  test "controling expiration date" do
    coder = ThreeScale::SSO::Encryptor.new ThreeScale::SSO.generate_sso_key, 60
    token = coder.encrypt_token "user_id"

    Timecop.travel(3.minutes.from_now) do
      assert_raise(ThreeScale::SSO::ValidationError) { coder.extract! token }
    end
  end
end
