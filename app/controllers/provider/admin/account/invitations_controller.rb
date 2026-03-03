# frozen_string_literal: true

class Provider::Admin::Account::InvitationsController < Provider::Admin::Account::BaseController
  before_action :authorize_multiple_users
  before_action :set_resource
  before_action :load_invitation, only: [:destroy, :resend]

  authorize_resource

  activate_menu :account, :users, :invitations

  def index
    @invitations = invitations
  end

  def new
    @invitation = invitations.build
  end

  def create
    @invitation = invitations.build(invitation_params)

    if @invitation.save
      redirect_to provider_admin_account_invitations_path, success: t('.success')
    else
      render :new
    end
  end

  def destroy
    @invitation.destroy
    redirect_to provider_admin_account_invitations_path, success: t('.success')
  end

  def resend
    @invitation.resend

    respond_to do |format|
      format.html { redirect_to provider_admin_account_invitations_path, success: t('.success') }
      format.xml  { head :ok } # TODO: figure out if this is still used or it needs to be cleaned up
    end
  end

  private

  def authorize_multiple_users
    authorize! :manage, :multiple_users
  end

  def invitations
    @invitations ||= @account.invitations
  end

  def load_invitation
    @invitation = invitations.find(params[:id])
  end

  def set_resource
    @account = current_account
  end

  def invitation_params
    params.require(:invitation).permit(:email)
  end
end
