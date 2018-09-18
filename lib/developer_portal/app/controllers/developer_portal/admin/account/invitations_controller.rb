module DeveloperPortal
  class Admin::Account::InvitationsController < ::DeveloperPortal::ApplicationController

    before_action :ensure_buyer_domain
    before_action :authorize_multiple_users

    inherit_resources
    defaults :route_prefix => 'admin_account'
    actions :index, :new, :create, :destroy

    authorize_resource

    activate_menu :account, :users

    helper_method :return_path

    liquify prefix: 'invitations'

    def index
      invitations = Liquid::Drops::Invitation.wrap(collection)
      pagination = Liquid::Drops::Pagination.new(collection, self)
      assign_drops invitations: invitations, pagination: pagination
    end

    create! do |success, failure|
      success.html { redirect_to return_path }
      failure.html do
        assign_drops invitation: @invitation
        render 'new'
      end
    end

    destroy! do |success, failure|
      success.html { redirect_to return_path }
      success.xml  { head :ok }
    end

    def resend
      @invitation = current_account.invitations.find params[:id]
      @invitation.resend
      flash[:notice] = "Invitation was resent"
      redirect_to return_path
    end

    private

    def authorize_multiple_users
      authorize! :see, :multiple_users
    end

    def collection
      @invitations ||= end_of_association_chain.paginate(:page => params[:page])
    end

    def begin_of_association_chain
      current_account
    end

    def return_path
      admin_account_invitations_path
    end
  end
end
