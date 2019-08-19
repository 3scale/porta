# frozen_string_literal: true

module ApiAuthentication
  module HttpAuthentication
    def http_authentication(*)
      authorization = request.authorization

      return if authorization.blank? || !authorization&.valid_encoding?

      decoded = ActionController::HttpAuthentication::Basic
                    .user_name_and_password(request).find(&:presence)

      decoded&.scrub
    rescue ArgumentError # invalid byte sequence
    end
  end
end
