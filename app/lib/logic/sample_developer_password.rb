# frozen_string_literal: true

module Logic
  module SampleDeveloperPassword
    SALT      = "onboarding.v1.sample-developer-password"
    KEY_BYTES = 32
    LENGTH    = ::Authentication::ByPassword::STRONG_PASSWORD_MIN_SIZE

    def self.subkey
      Rails.application.key_generator.generate_key(SALT, KEY_BYTES)
    end

    def self.for(provider)
      mac = OpenSSL::HMAC.digest("SHA256", subkey, "#{provider.id}:#{provider.created_at.to_i}")
      Base64.urlsafe_encode64(mac, padding: false)[0, LENGTH]
    end
  end
end
