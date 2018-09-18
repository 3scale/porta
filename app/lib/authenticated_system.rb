module AuthenticatedSystem
  protected

  # TODO: this module should be reviewed, because it seems to contain stuff that has
  # nothing to do with authentication. That stuff should be moved somewhere else.

  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.class_eval do

      helper_method :admin?, :authorized?, :current_account, :current_user,
                    :logged_in?, :owner?, :current_site, :admin? if respond_to?(:helper_method)

      prepend_before_action :clear_current_user
      after_action :update_current_user_after_login
    end
  end

  def reset_session
    destroy_user_session!
    clear_current_user
    super
  end
  public :reset_session # required by protect_from_forgery with: :reset_session

  # TODO: move this to middleware
  def clear_current_user
    @current_user = User.current = nil
    authenticated_request.reset!
  end

  # Feel freee to add skip_after_action for this method in controllers for stats or api transactions
  def update_current_user_after_login
    handle_remember_cookie!(params[:remember_me] == "1")
    user_session.access(request) if user_session
  end

  delegate :user_session, to: :authenticated_request

  def authenticated_request
    @_authenticated_request ||= AuthenticatedSystem::Request.new(request)
  end

  def create_user_session!(authentication_provider_id = nil)
    # if authentication_provider_id exist, sso provider has been used
    # last updated sso authorization is the current one
    sso_authorization_id = if authentication_provider_id.present?
                             current_user.sso_authorizations
                               .where(authentication_provider_id: authentication_provider_id)
                               .newest.try(:id)
                           end
    us = current_user.user_sessions.build(sso_authorization_id: sso_authorization_id)
    us.access(request)

    cookies.signed[:user_session] = {
      :value    => us.key,
      :httponly => true,
      # A secure cookie has the secure attribute enabled and is only used via HTTPS, ensuring that the cookie is always encrypted when transmitting from client to server. This makes the cookie less likely to be exposed to cookie theft via eavesdropping.
      :secure   => System::Application.config.three_scale.secure_cookie
    }

    us
  end

  def destroy_user_session!
    logger.info "Destroying user session #{user_session.to_param}"
    user_session.try!(:revoke!)
    cookies.delete :user_session
    @user_session = nil
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def provider_admin_for?(site_account)
    current_account && current_account == site_account
  end

  # Returns true or false if the user is logged in.
  def logged_in?
    !!current_user
  end

  # Accesses the current user from the session.
  # Future calls avoid the database because nil is not equal to false.
  def current_user
    @current_user ||= (login_from_user_session || login_from_remember_me_cookie) unless @current_user == false
  end

  # Store the given user id in the session.
  def current_user=(new_user)
    @current_user = if new_user
      User.current = new_user
                    else
      false
                    end
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_action :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_action :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_action :login_required
  #
  def login_required
    logged_in? or unauthenticated
  end

  def unauthenticated
    request_login
  end

  def request_login
    store_location
    flash.keep

    if Account.is_admin_domain?(request.host) || site_account.master?
      redirect_to_login_for_providers
    else
      redirect_to_login_for_buyers
    end
  end

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.fullpath
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.  Set an appropriately modified
  #   after_action :store_location, :only => [:index, :new, :show, :edit]
  # for any controller you want to be bounce-backable.
  def redirect_back_or_default(default)
    url = URI.parse(url_for(session[:return_to] || default))

    redirect_to(url.select(:path, :query).compact.join('?'))
  ensure
    session[:return_to] = nil
  end

  #
  # Login
  #

  # Called from #current_user. First attempt to login by the user session stored in the cookie.
  def login_from_user_session
    if user_session && user_session.user && defined?(site_account)
      self.current_user = authenticated_request.current_user
    end
  end

  # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
  # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
  def login_from_remember_me_cookie
    user = cookies[:auth_token] && defined?(site_account) && site_account.managed_users.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      self.current_user = user
      handle_remember_cookie! false # freshen cookie token (keeping date)
      current_user
    end
  end

  #
  # Logout
  #

  # This is usually what you want; resetting the session willy-nilly wreaks
  # havoc with forgery protection, and is only strictly necessary on login.
  # However, **all session state variables should be unset here**.
  def logout_keeping_session!
    # Kill server-side auth cookie
    @current_user.forget_me if @current_user.respond_to?(:forget_me)
    @current_user = false     # not logged in, and don't do it for me
    kill_remember_cookie!     # Kill client-side auth cookie
    session[:user_id] = nil   # keeps the session but kill our variable
    # explicitly kill any other session variables you set
  end

  # The session should only be reset at the tail end of a form POST --
  # otherwise the request forgery protection fails. It's only really necessary
  # when you cross quarantine (logged-out to logged-in).
  def logout_killing_session!
    logout_keeping_session!
    cms_token = session[:cms_token]
    reset_session
    session[:cms_token] = cms_token if cms_token
  end

  # Remember_me Tokens
  #
  # Cookies shouldn't be allowed to persist past their freshness date,
  # and they should be changed at each login

  # Cookies shouldn't be allowed to persist past their freshness date,
  # and they should be changed at each login

  def valid_remember_cookie?
    return nil unless @current_user
    (@current_user.remember_token?) &&
      (cookies[:auth_token] == @current_user.remember_token)
  end

  # Refresh the cookie auth token if it exists, create it otherwise
  def handle_remember_cookie! new_cookie_flag
    return unless @current_user
    case
    when valid_remember_cookie? then @current_user.refresh_token # keeping same expiry date
    when new_cookie_flag        then @current_user.remember_me
    else                             @current_user.forget_me
    end
    send_remember_cookie!
  end

  def kill_remember_cookie!
    cookies.delete :auth_token
  end

  def send_remember_cookie!
    cookies[:auth_token] = {
      :value   => @current_user.remember_token,
      :expires => @current_user.remember_token_expires_at }
  end

  # Account of current user, or nil if no one is logged in.
  def current_account
    @current_account || (current_user && current_user.account)
  end

  # Used when there is no "current_user" present, i.e. API calls with provider_key.
  def current_account=(account)
    @current_account = account
  end

  # This redirects to provider login screen
  def redirect_to_login_for_providers
    redirect_to provider_login_path
  end

  # This redirects to login screen for buyers
  def redirect_to_login_for_buyers
    if site_account.settings.sso_login_url.blank?
      redirect_to developer_portal.login_path
    else
      redirect_to site_account.settings.sso_login_url
    end
  end

  def owner?(object_belonging_to_account)
    logged_in? && current_user.account.id == object_belonging_to_account.account_id
  end
end
