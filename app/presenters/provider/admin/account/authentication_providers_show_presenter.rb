# frozen_string_literal: true

class Provider::Admin::Account::AuthenticationProvidersShowPresenter

  attr_reader :authentication_provider, :publishing_service

  def initialize(authentication_provider)
    @authentication_provider = authentication_provider
    @account = @authentication_provider.account
    @publishing_service = AuthenticationProviderPublishValidator.new(@account, @authentication_provider)
  end

  def cannot_edit?
    @account.settings.enforce_sso? && @authentication_provider.sso_authorizations.any?
  end

  def oauth_flow_tested_at_formatted
    tested_at = @publishing_service.authentication_provider_tested_at
    I18n.localize(tested_at, format: :short) if tested_at
  end

  def test_link_text
    I18n.t("authentication_provider.test_link.#{@publishing_service.tested_state}")
  end

  def test_text_short
    @publishing_service.tested_state.to_s
  end

  def authentication_provider_hidden_or_visible
    @authentication_provider.published ? 'Visible' : 'Hidden'
  end

  def authentication_provider_publish_or_unpublish
    @authentication_provider.published ? 'Unpublish' : 'Publish'
  end

  def publishing_method
    @authentication_provider.published? ? :delete : :create
  end
end
