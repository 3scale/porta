# frozen_string_literal: true

class Provider::Admin::Account::EnforceSSOController < Provider::Admin::Account::BaseController

  before_action :enforce_sso_allowed?, only: [:create]

  def create
    if current_account.settings.update_attributes(enforce_sso: true)
      logout_all_password_users
      redirect_to index_path, notice: 'SSO successfully enforced'
    else
      redirect_to index_path, flash: {error: 'SSO could not be enforced'}
    end
  end

  def destroy
    if current_account.settings.update_attributes(enforce_sso: false)
      redirect_to index_path, notice: 'SSO enforcement successfully disabled'
    else
      redirect_to index_path, flash: {error: 'SSO enforcement could not be disabled'}
    end
  end

  private

  def logout_all_password_users
    current_account.user_sessions.password_only.delete_all
  end

  def enforce_sso_allowed?
    enforce_sso = EnforceSSOValidator.new(user_session)

    return if enforce_sso.valid?
    redirect_to index_path, flash: {error: enforce_sso.error_message}
  end

  def index_path
    provider_admin_account_authentication_providers_path
  end
end
