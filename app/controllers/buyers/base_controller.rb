#TODO: make all buyers controllers inherit from this one, e.g. accounts, users
class Buyers::BaseController < FrontendController
  before_action :ensure_provider_domain
  before_action :authorize_partners

  inherit_resources
  defaults :route_prefix => 'admin_buyers'

  activate_menu :buyers

  protected

  def authorize_partners
    authorize! :manage, :partners
  end

  def find_account
    @account = current_account.buyers.find params[:account_id]
  end
end
