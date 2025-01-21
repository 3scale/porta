# frozen_string_literal: true

class Provider::Admin::Account::UsersIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_user:, users:, params:)
    @ability = Ability.new(current_user)

    pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }

    @users = users.paginate(pagination_params)
  end

  attr_reader :users

  def toolbar_props
    props = {
      totalEntries: @users.total_entries,
      pageEntries: @users.length,
      actions: [],
    }

    if can?(:create, Invitation) && can?(:see, :multiple_users)
      props[:actions] << {
        variant: :primary,
        label: t('.invite_new_user'),
        href: new_provider_admin_account_invitation_path
      }
    end

    props
  end

  def show_provider_sso_status_for_user?(account)
    @show_provider_sso_status_for_user ||= account.provider_can_use?(:provider_sso) &&
                                           account.self_authentication_providers.published.any?
  end

  def show_permission_groups?
    @show_permission_groups ||= can?(:manage, :permissions)
  end

  def permission_groups(user)
    if user.admin?
      t('.unlimited_access')
    else
      member_permission_ids = user.member_permission_ids
      return '-' if member_permission_ids.empty?

      I18n.t('admin_sections.permission_groups_summary').values_at(*member_permission_ids).join(', ')
    end
  end

  private

  attr_reader :ability

  delegate :can?, to: :ability

  def t(key)
    I18n.t("provider.admin.account.users.index#{key}")
  end
end
