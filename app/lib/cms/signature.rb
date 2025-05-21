# frozen_string_literal: true

module CMS
  class Signature
    def self.generate(provider_id, expires_at)
      verifier = Rails.application.message_verifier(:provider_id)
      signing_options = { purpose: :cms_edit_mode, expires_at: expires_at.utc.floor }
      verifier.generate(provider_id, **signing_options).split("--").last
    end
  end
end
