class Provider::PasswordsController < FrontendController

  skip_before_action :login_required, only: %i(destroy show update)
  before_action :find_provider
  before_action :find_user, :only => [:show, :update]
  before_action :instantiate_sessions_presenter, only: [:show, :update]
  before_action :passwords_allowed?

  def new
    return redirect_to :back, error: t('.has_password') if current_user.using_password?

    reset_session_password_token
    token = current_user.generate_lost_password_token
    redirect_to provider_password_path(password_reset_token: token)
  end

  def destroy
    reset_session_password_token
    if user = @provider.users.find_by_email(email)
      user.generate_lost_password_token!
      flash[:notice] = "A password reset link has been emailed to you."
      redirect_to provider_login_path
    else
      flash[:error] = 'Email not found.'
      redirect_to provider_login_path(:request_password_reset => true)
    end
  end

  def show
    if params[:password_reset_token].present? && session[:password_reset_token].blank?
      new_token = @user.generate_lost_password_token
      session[:password_reset_token] = new_token
      redirect_to provider_password_path
    end
  end

  def update
    user = params[:user]
    if @user.update_password(user[:password], user[:password_confirmation] )
      reset_session_password_token
      flash[:notice] = "The password has been changed."
      @user.kill_user_sessions
      redirect_to provider_login_path
    else
      render :action => 'show'
    end
  end

  private

  # Can't be used for neither Buyer nor Master
  #
  def find_provider
    unless @provider ||= Account.providers.find_by_self_domain(request.host.to_s)
      render_error "Wrong domain '#{request.host}' for path '#{request.path}'", status: 404
      false
    end
  end

  def find_user
    @user = @provider.users.find_with_valid_password_token(password_reset_token)
    unless @user
      flash[:error] = 'The password reset token is invalid.'
      redirect_to provider_login_path
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
    redirect_to provider_login_path, flash: {error: 'Password login has been disabled.'}
  end
end
