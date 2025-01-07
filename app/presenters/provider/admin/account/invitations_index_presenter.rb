# frozen_string_literal: true

class Provider::Admin::Account::InvitationsIndexPresenter
  include System::UrlHelpers.system_url_helpers
  include InvitationsHelper

  alias status invitation_status
  alias sent_date invitation_sent_date

  def initialize(invitations, user, params)
    @ability = Ability.new(user)
    pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    sorting_params = "#{params[:sort].presence || 'sent_at'} #{params[:direction].presence || 'desc'}"
    @invitations = invitations.paginate(pagination_params)
                              .reorder(sorting_params)
  end

  attr_reader :invitations

  def empty_state?
    @invitations.total_entries.zero?
  end

  def can_send_invitations?
    @ability.can?(:create, Invitation) && @ability.can?(:see, :multiple_users)
  end

  def can_manage_invitation?(invitation)
    @ability.can?(:manage, invitation)
  end

  def toolbar_props
    {
      totalEntries: @invitations.total_entries,
      actions: [{
        variant: :primary,
        label: I18n.t('provider.admin.account.invitations.index.send_invitation_title'),
        href: new_provider_admin_account_invitation_path
      }]
    }
  end

end
