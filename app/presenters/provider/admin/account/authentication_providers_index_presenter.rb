# frozen_string_literal: true

class Provider::Admin::Account::AuthenticationProvidersIndexPresenter
  include ::Draper::ViewHelpers
  include System::UrlHelpers.system_url_helpers

  attr_reader :raw_authentication_providers, :sorting_params, :pagination_params

  def initialize(user:, authentication_providers:, session:, params:)
    @user = user
    @raw_authentication_providers = authentication_providers
    @enforce_sso_service = EnforceSSOValidator.new(session)

    @sorting_params = "#{params[:sort].presence || 'updated_at'} #{params[:direction].presence || 'desc'}"
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
  end

  def authentication_providers
    @authentication_providers ||= raw_authentication_providers.order(sorting_params)
                                                              .paginate(pagination_params)
  end

  def sso_enforced?
    @sso_enforced ||= @user.account.settings.enforce_sso?
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

    raw_authentication_providers.any?
  end

  def enable_toggle?
    # re-enabling password sign-ins should always be possible
    return true if passwords_disabled?

    @enforce_sso_service.valid?
  end

  def disable_toggle?
    !enable_toggle?
  end

  def props
    {
      showToggle: show_toggle?,
      ssoEnabled: sso_enforced?,
      toggleDisabled: disable_toggle?,
      table: table_data.as_json,
      ssoPath: provider_admin_account_enforce_sso_path
    }
  end

  def table_data
    {
      count: raw_authentication_providers.size,
      deleteTemplateHref: provider_admin_account_authentication_provider_path(id: ':id'),
      items: authentication_providers.map { |ap| to_table_data(ap) },
      newHref: new_provider_admin_account_authentication_provider_path,
    }
  end

  private

  def to_table_data(auth_provider)
    tested = Provider::Admin::Account::AuthenticationProvidersShowPresenter.new(auth_provider).test_text_short

    {
      id: auth_provider.id,
      createdOn: auth_provider.created_at.to_date.to_s(:long),
      name: auth_provider.human_kind,
      editPath: edit_provider_admin_account_authentication_provider_path(auth_provider),
      path: provider_admin_account_authentication_provider_path(auth_provider),
      published: auth_provider.published?,
      state: "#{auth_provider.published ? 'Visible' : 'Hidden'} (#{tested})",
      users: auth_provider.sso_authorizations.count,
    }
  end
end
