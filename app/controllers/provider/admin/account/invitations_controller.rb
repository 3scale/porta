class Provider::Admin::Account::InvitationsController < Provider::Admin::Account::BaseController
  before_action :authorize_multiple_users
  before_action :set_resource
  activate_menu :account, :invitations

  inherit_resources
  belongs_to :account


  create! do |success, failure|
    success.html do
      redirect_to provider_admin_account_invitations_path,
                  notice: 'Invitation was successfully sent.'
    end
  end

  destroy! do |success, failure|
    success.html { redirect_to(provider_admin_account_invitations_path) }
  end

  def resend
    @invitation = @account.invitations.find(params[:id])
    @invitation.resend

    respond_to do |format|
      format.html do
        flash[:success] = "Invitation was successfully resent"
        redirect_to provider_admin_account_invitations_path
      end
      format.xml  { head :ok }
    end
  end

  private

  def authorize_multiple_users
    authorize! :manage, :multiple_users
  end

  def collection
    @invitations ||= end_of_association_chain.paginate(:page => params[:page])
  end

  def set_resource
    @account = current_account
  end
end
