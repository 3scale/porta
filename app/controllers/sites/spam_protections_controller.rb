class Sites::SpamProtectionsController < Sites::BaseController
  activate_menu :audience, :cms, :spam_protection

  before_action :find_settings

  def edit
  end

  def update
    if @settings.update(params[:settings])
      redirect_to edit_admin_site_spam_protection_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

end
