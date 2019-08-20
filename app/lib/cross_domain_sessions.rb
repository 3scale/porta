# Include this module into a controller to enable sessions that persist over multiple domains.
module CrossDomainSessions
  private

  def login_required
    if params[:session_token].present?
      logout_keeping_session!
      self.current_user = User.authenticate_by_session_token(params[:session_token])
    end

    super
  end
end
