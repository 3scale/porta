module ApiAuthentication
  module HttpAuthentication
    def http_authentication(*)
      authorization = request.authorization

      return if authorization.blank? || !authorization.try!(:valid_encoding?)

      decoded = ActionController::HttpAuthentication::Basic
                    .user_name_and_password(request).find(&:presence)

      decoded.try!(:scrub)
    rescue ArgumentError # invalid byte sequence
    end
  end
end
