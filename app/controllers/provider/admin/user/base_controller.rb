class Provider::Admin::User::BaseController < Provider::Admin::BaseController
  activate_menu! topmenu: :account, main_menu: :personal

  before_action :authorize_resource!

  layout 'provider'

  protected

  def authorize_resource!
    authorize! [:read, :update], current_user
  end
end
