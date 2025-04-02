# frozen_string_literal: true

module Impersonate
  class Signature
    def self.generate(user_id, expires_at)
      verifier = Rails.application.message_verifier(:impersonate)
      signing_options = { purpose: :impersonate_admin_login, expires_at: expires_at.utc.floor }
      verifier.generate(user_id, **signing_options).split("--").last
    end

    def self.validate(params, user_id)
      signature = params.delete(:signature)
      return signature if signature.blank?

      expires_at = Time.at(params.delete(:expires_at).to_i).utc
      raise ActiveSupport::MessageVerifier::InvalidSignature unless expires_at > Time.now.utc

      valid_signature = signature == generate(user_id, expires_at)

      raise ActiveSupport::MessageVerifier::InvalidSignature unless valid_signature

      true
    rescue StandardError
      false
    end
  end
end
