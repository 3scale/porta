# frozen_string_literal: true

class Provider::Admin::Account::EnforceSSOController < Provider::Admin::Account::BaseController

  before_action :enforce_sso_allowed?, only: [:create]

  def create
    if current_account.settings.update(enforce_sso: true)
      logout_all_password_users
      render json: { notice: t('.success') }
    else
      render json: { error: t('.error') }
    end
  end

  def destroy
    if current_account.settings.update(enforce_sso: false)
      render json: { notice: t('.success') }
    else
      render json: { error: t('.error') }
    end
  end

  private

  def logout_all_password_users
    current_account.user_sessions.password_only.delete_all
  end

  def enforce_sso_allowed?
    enforce_sso = EnforceSSOValidator.new(user_session)

    return if enforce_sso.valid?

    render json: { error: enforce_sso.error_message }
  end

  def index_path
    provider_admin_account_authentication_providers_path
  end
end
