class Buyer::BulkApprovalsController < FrontendController
  include SiteAccountSupport
  include ProviderRequirements

  #FIXME: this controller now is acting as a provider one!!!
  # this should be fixed when the namespaces mess is clean in the app

  require_provider_admin
  activate_menu :partners

  def update
    @account_ids = params[:account_ids]
    @state_action = if params[:commit] == "Approve Selected"  ||
                        params[:commit] == "Approve"
                      "approve"
                    elsif params[:commit] == "Reject Selected" ||
                        params[:commit] == "Reject"
                      "reject"
                    end

    if params[:confirm] == 'confirmed'
      if(@state_action == 'approve')
        Account.bulk_approve(params[:account_ids])
      end

      if(@state_action == 'reject')
        Account.bulk_reject(params[:account_ids])
      end
      flash[:notice] = "Selected accounts have been updated."
      redirect_to buyer_accounts_path(:kind => :pending)
    else
      render(:action => :show)
    end
  end

  def show
  end
end
