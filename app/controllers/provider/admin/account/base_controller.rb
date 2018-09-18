class Provider::Admin::Account::BaseController < Provider::Admin::BaseController
  activate_menu! :topmenu => :account, :main_menu => :account

  before_action :authorize_resource!

  layout 'provider'

  protected

  def authorize_resource!
    authorize! :manage, current_account
  end
end
