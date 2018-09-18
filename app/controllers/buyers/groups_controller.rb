class Buyers::GroupsController < Buyers::BaseController
  before_action :authorize_groups
  before_action :find_account
  activate_menu :submenu => :accounts

  def show
    @groups = @account.groups
    @page_title = "Groups of #{@account.org_name}"
  end

  def update
    if @account.update_attributes params[:account]
      flash[:notice]= "Account updated"
    end

    redirect_to :action => :show, :id => @account.id
  end

  protected

  def authorize_groups
    authorize! :manage, :groups
  end

  def find_account
    @account = current_account.buyer_accounts.find(params[:account_id])
  end
end
