# frozen_string_literal: true

module User::ProvidedAccessTokens
  extend ActiveSupport::Concern

  included do
    has_many :provided_access_tokens, extend: ::User::ProvidedAccessTokens::ModelExtensions
  end

  module ModelExtensions
    def create_from_access_token!(access_token)
      create!(
        value: access_token.token,
        expires_at: Time.at(access_token.expires_at)
      )
    end
  end
end
