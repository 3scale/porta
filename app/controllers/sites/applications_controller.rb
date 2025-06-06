class Sites::ApplicationsController < Sites::BaseController

  before_action :find_account
  before_action :authorize

  def edit
  end

  def update
    if @account.update(params[:account])
      redirect_to admin_site_settings_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
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
