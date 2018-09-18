class DeveloperPortal::Admin::Account::PasswordsController < ::DeveloperPortal::BaseController
  liquify prefix: 'password'

  skip_before_action :login_required
  before_action :find_provider
  before_action :find_user, :only => [:show, :update]

  def create
    if user = @provider.buyer_users.find_by_email(params[:email])
      user.generate_lost_password_token!
      flash[:notice] = "A password reset link has been emailed to you."
      redirect_to login_url
    else
      flash[:error] = 'Email not found.'
      redirect_to new_admin_account_password_url(:request_password_reset => true) # keep hash for retrocompatibility
    end
  end

  def new; end

  def show
    assign_drops password_reset_token: @token
  end

  def update
    if password_params[:password].present? && @user.update_attributes(password_params)
      @user.expire_password_token
      flash[:notice] = "The password has been changed."
      redirect_to login_url
    else
      flash[:error] = "The password is invalid"
      assign_drops password_reset_token: @token, user: @user
      render :action => 'show'
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def find_user
    @token = params[:password_reset_token]
    @user = @provider.buyer_users.find_with_valid_password_token(@token)

    unless @user
      flash[:error] = 'The password reset token is invalid.'
      redirect_to login_url
    end
  end

  def find_provider
    @provider = site_account

    unless @provider.provider?
      render_error "Wrong domain '#{request.host}' for path '#{request.path}'"
      false
    end
  end

end
