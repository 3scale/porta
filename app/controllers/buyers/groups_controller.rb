class Buyers::GroupsController < Buyers::BaseController
  before_action :authorize_groups
  before_action :find_account
  activate_menu :audience, :accounts, :listing


  def show
    @groups = @account.groups
    @page_title = t('.page_title', org_name: @account.org_name)
  end

  def update
    if @account.update params[:account]
      flash[:success] = t('.success')
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
