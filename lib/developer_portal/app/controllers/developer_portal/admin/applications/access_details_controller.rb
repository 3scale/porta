class DeveloperPortal::Admin::Applications::AccessDetailsController < ::DeveloperPortal::BaseController

  before_action :find_cinstance
  activate_menu :dashboard

  liquify

  def show
    if @cinstance
      assign_drops application: @cinstance
      assign_drops referrer_filter: ReferrerFilter.new(application: @cinstance)
      render 'applications/show'
    else
      redirect_to new_admin_application_url
    end
  end

  def regenerate_user_key
    authorize! :regenerate_user_key , @cinstance
    @cinstance.change_user_key!

    redirect_to admin_applications_access_details_url, notice: 'The user key was regenerated.'
  end

  private

  def find_cinstance
    if current_account.has_bought_cinstance?
      @cinstance = current_account.bought_cinstance
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
