# frozen_string_literal: true

class Provider::Admin::Account::AuthenticationProvidersIndexPresenter

  attr_reader :authentication_providers

  def initialize(user, authentication_providers, user_session)
    @authentication_providers = authentication_providers
    @account = user.account
    @user_sso_authorizations = user.sso_authorizations
    @enforce_sso_service = EnforceSSOValidator.new(user_session)
  end

  def sso_enforced?
    @account.settings.enforce_sso?
  end

  def passwords_enabled?
    !passwords_disabled?
  end

  def passwords_disabled?
    sso_enforced?
  end

  def method
    sso_enforced? ? :delete : :create
  end

  def show_toggle?
    # re-enabling password sign-ins should always be possible
    return true if passwords_disabled?
    @account.self_authentication_providers.any?
  end

  def enable_toggle?
    # re-enabling password sign-ins should always be possible
    return true if passwords_disabled?
    @enforce_sso_service.valid?
  end

  def disable_toggle?
    !enable_toggle?
  end

  def authentication_provider_locked?(authentication_provider)
    sso_enforced? && authentication_provider.sso_authorizations.any?
  end

  private

  def all_authorizations_have_published_auth_provider?
    @user_sso_authorizations.all? {|auth| auth.authentication_provider.published?}
  end

  def existing_authorization?
    @user_sso_authorizations.exists?
  end
end
