module DeveloperPortal
  class Admin::Account::InvitationsController < ::DeveloperPortal::ApplicationController

    before_action :ensure_buyer_domain
    before_action :authorize_multiple_users
    before_action :load_invitation, only: %i[destroy resend]

    authorize_resource

    activate_menu :account, :users

    helper_method :return_path

    liquify prefix: 'invitations'

    def index
      invitations = Liquid::Drops::Invitation.wrap(collection)
      pagination = Liquid::Drops::Pagination.new(collection, self)
      assign_drops invitations: invitations, pagination: pagination
    end

    def new
      @invitation = invitations.build
      assign_drops invitation: @invitation
    end

    def create
      @invitation = invitations.build(invitation_params)

      if @invitation.save
        redirect_to return_path
      else
        assign_drops invitation: @invitation
        render 'new'
      end
    end

    def destroy
      @invitation.destroy
      respond_to do |format|
        format.html { redirect_to return_path }
        format.xml  { head :ok }
      end
    end

    def resend
      @invitation.resend
      flash[:notice] = "Invitation was resent"
      redirect_to return_path
    end

    private

    def authorize_multiple_users
      authorize! :see, :multiple_users
    end

    def invitations
      @invitations ||= current_account.invitations
    end

    def collection
      @collection ||= invitations.paginate(page: params[:page])
    end

    def load_invitation
      @invitation = invitations.find(params[:id])
    end

    def invitation_params
      params.require(:invitation).permit(:email)
    end

    def return_path
      admin_account_invitations_path
    end
  end
end
