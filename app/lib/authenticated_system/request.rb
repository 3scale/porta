module AuthenticatedSystem
  class Request

    attr_reader :request

    delegate :site_account, to: :site_account_request

    delegate :user_id, to: :user_session
    delegate :account_id, to: :current_user, allow_nil: true

    private :request

    def initialize(request)
      @request = request
    end

    def authenticated?
      !!current_user
    end

    def current_user
      @_current_user ||= site_account.managed_users.find_by_id(user_session.user_id)
    end

    def user_session
      @_user_session ||= UserSession.authenticate(cookies.signed[:user_session]) || UserSession.null
    end

    def reset!
      @_current_user = @_user_session = nil
    end

    def zync?
      header_value = request.headers['X-Zync-Token']
      zync_authentication_token = ThreeScale.config.zync_authentication_token
      header_value.present? && zync_authentication_token.present? && ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(header_value),
        ::Digest::SHA256.hexdigest(zync_authentication_token)
      )
    end

    private

    def cookies
      request.cookie_jar
    end

    def site_account_request
      @_site_account_request ||= SiteAccountSupport::Request.new(request)
    end

  end
end
