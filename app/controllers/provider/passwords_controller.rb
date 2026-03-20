class Provider::PasswordsController < FrontendController

  skip_before_action :login_required, only: %i[destroy show update reset]
  before_action :find_provider
  before_action :find_user, :only => [:show, :update]
  before_action :instantiate_sessions_presenter, only: [:show, :update]
  before_action :passwords_allowed?

  def new
    return redirect_back_or_to(root_path), danger: t('.has_password') if current_user.already_using_password?

    reset_session_password_token
    token = current_user.generate_lost_password_token
    redirect_to provider_password_path(password_reset_token: token)
  end

  def destroy
    reset_session_password_token
    if (user = @provider.users.find_by(email: email))
      user.generate_lost_password_token!
    end
    redirect_to provider_login_path, success: t('.success', email: email)
  end

  def show
    if password_params[:password_reset_token].present? && session[:password_reset_token].blank?
      new_token = @user.generate_lost_password_token
      session[:password_reset_token] = new_token
      redirect_to provider_password_path
    end
  end

  def update
    user = password_params[:user]
    if @user.update_password(user[:password], user[:password_confirmation] )
      reset_session_password_token
      @user.kill_user_sessions
      redirect_to provider_login_path, success: t('.success')
    else
      render :action => 'show'
    end
  end

  def reset
    redirect_to provider_admin_dashboard_url if logged_in?
  end

  private

  # Can't be used for neither Buyer nor Master
  #
  def find_provider
    host = request.internal_host
    @provider ||= Account.tenants.find_by(self_domain: host)
    return if @provider

    render_error "Wrong domain '#{host}' for path '#{request.path}'", status: 404
    false
  end

  def find_user
    @user = @provider.users.find_with_valid_password_token(password_reset_token)
    unless @user
      redirect_to provider_login_path, danger: t('.error')
    end
  end

  def email
    params.fetch(:email).to_s
  end

  def reset_session_password_token
    session[:password_reset_token] = nil
  end

  def password_reset_token
    session[:password_reset_token].presence || params.fetch(:password_reset_token).to_s
  end

  def instantiate_sessions_presenter
    @presenter = Provider::SessionsPresenter.new(@provider)
  end

  def passwords_allowed?
    return unless @provider.settings.enforce_sso?

    redirect_to provider_login_path, warning: t('.password_login_disabled')
  end

  def password_params
    params.permit(:password_reset_token, user: %i[password password_confirmation])
  end
end
