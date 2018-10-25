class Provider::Admin::User::BaseController < Provider::Admin::BaseController
  activate_menu :account, :personal

  before_action :authorize_resource!

  layout 'provider'

  protected

  def authorize_resource!
    authorize! [:read, :update], current_user
  end
end
