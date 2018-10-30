class Buyers::InvitationsController < Buyers::BaseController
  before_action :authorize_multiple_users
  before_action :find_account

  activate_menu :audience, :accounts, :listing

  #actions :index, :new, :create, :destroy, :resend
  #defaults :route_prefix => 'admin_buyers' #FIXME inherited_resource makes us repeat this
  #I'm starting to believe this controller belongs to a deeper nesting under buyers
  belongs_to :account

  create! do |success, failure|
    success.html do
      redirect_to admin_buyers_account_invitations_path(@account),
                  notice: 'Invitation was successfully sent.'
    end
  end

  destroy! do |success, failure|
    success.html { redirect_to(admin_buyers_account_invitations_path(@account)) }
  end

  def resend
    @invitation = Invitation.find(params[:id])
    @invitation.resend

    respond_to do |format|
      format.html do
        flash[:success] = "Invitation was successfully resent"
        redirect_to(admin_buyers_account_invitations_path(@account))
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

  def find_account
    @account = Account.find params[:account_id] unless params[:account_id].empty?
  end
end
