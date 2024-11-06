# frozen_string_literal: true

module CMS
  class Signature
    def self.generate(token, expires_at)
      verifier = Rails.application.message_verifier(:cms_token)
      signing_options = { purpose: :cms_edit_mode, expires_at: expires_at.utc.floor }
      verifier.generate(token.b, **signing_options).split("--").last
    end
  end
end
