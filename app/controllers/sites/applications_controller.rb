class Sites::ApplicationsController < Sites::BaseController

  before_action :find_account
  before_action :authorize

  def edit
  end

  def update
    if @account.update_attributes(params[:account])
      flash[:notice] = 'The applications settings were updated.'
      redirect_to admin_site_settings_url
    else
      flash[:error] = 'There were problems saving the settings.'
      render :action => 'edit'
    end
  end

  private

  def find_account
    @account = current_account
  end

  def authorize
    authorize! :manage, :applications
  end

end
