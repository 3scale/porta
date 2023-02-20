# frozen_string_literal: true

class DeveloperPortal::Admin::Account::PasswordsController < ::DeveloperPortal::BaseController
  include ThreeScale::SpamProtection::Integration::Controller

  liquify prefix: 'password'

  skip_before_action :login_required
  before_action :find_provider
  before_action :find_user, :only => [:show, :update]

  def create
    return redirect_to_request_password('Spam protection failed.') unless spam_check(buyer)

    user = @provider.buyer_users.find_by_email(params[:email])
    return redirect_to_request_password('Email not found.') unless user

    user.generate_lost_password_token!
    flash[:notice] = 'A password reset link has been emailed to you.'
    redirect_to login_url
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

  def redirect_to_request_password(error_message)
    flash[:error] = error_message
    redirect_to new_admin_account_password_url(request_password_reset: true)
  end

  def buyer
    @buyer ||= @provider.buyers.build do |account|
      # We need to get all the account params to run the spam check
      account.unflattened_attributes = account_params
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def account_params
    params.fetch(:account, {})
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
      render_error "Wrong domain '#{request.internal_host}' for path '#{request.path}'"
      false
    end
  end

end
