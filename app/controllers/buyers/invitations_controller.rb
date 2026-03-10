class Buyers::InvitationsController < Buyers::BaseController
  before_action :authorize_multiple_users
  before_action :find_account
  before_action :load_invitation, only: [:destroy, :resend]

  activate_menu :audience, :accounts, :listing

  def index
    @invitations = invitations.paginate(page: params[:page])
  end

  def new
    @invitation = invitations.build
  end

  def create
    @invitation = invitations.build(invitation_params)

    if @invitation.save
      redirect_to admin_buyers_account_invitations_path(@account), success: t('.success')
    else
      render :new
    end
  end

  def destroy
    @invitation.destroy
    redirect_to admin_buyers_account_invitations_path(@account), success: t('.success')
  end

  def resend
    @invitation.resend

    respond_to do |format|
      format.html { redirect_to admin_buyers_account_invitations_path(@account), success: t('.success') }
      format.xml  { head :ok }
    end
  end

  private

  def authorize_multiple_users
    authorize! :manage, :multiple_users
  end

  def find_account
    @account = Account.find params[:account_id] unless params[:account_id].empty?
  end

  def load_invitation
    @invitation = invitations.find(params[:id])
  end

  def invitations
    @invitations ||= @account.invitations
  end

  def invitation_params
    params.require(:invitation).permit(:email)
  end
end
