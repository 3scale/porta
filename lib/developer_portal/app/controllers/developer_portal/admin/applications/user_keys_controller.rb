class DeveloperPortal::Admin::Applications::UserKeysController < ::DeveloperPortal::BaseController
  activate_menu :dashboard
  before_action :authorize_regenerate_user_key

  def update
    @cinstance = resource

    authorize! :regenerate_user_key , @cinstance
    @cinstance.change_user_key!

    flash[:notice] = 'The user key was regenerated.'

    redirect_to :back
  end

  private

  def authorize_regenerate_user_key
    authorize! :regenerate_user_key, resource
  end

  def collection
    current_account.bought_cinstances.can_be_managed
  end

  def resource
    resource = collection.find(params[:application_id])
    resource
  end
end
