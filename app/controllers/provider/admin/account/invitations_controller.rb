# frozen_string_literal: true

class Provider::Admin::Account::InvitationsController < Provider::Admin::Account::BaseController
  before_action :authorize_multiple_users
  before_action :set_resource
  activate_menu :account, :users, :invitations

  inherit_resources
  belongs_to :account

  create! do |success, failure|
    success.html { redirect_to provider_admin_account_invitations_path, notice: t('.success') }
  end

  destroy! do |success, failure|
    success.html { redirect_to(provider_admin_account_invitations_path) }
  end

  def resend
    @invitation = @account.invitations.find(params[:id])
    @invitation.resend

    respond_to do |format|
      format.html { redirect_to provider_admin_account_invitations_path, notice: t('.success') }
      format.xml  { head :ok } # TODO: figure out if this is still used or it needs to be cleaned up
    end
  end

  private

  def authorize_multiple_users
    authorize! :manage, :multiple_users
  end

  def collection
    @collection ||= end_of_association_chain
  end

  def set_resource
    @account = current_account
  end
end
