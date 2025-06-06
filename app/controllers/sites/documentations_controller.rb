# frozen_string_literal: true

class Sites::DocumentationsController < Sites::BaseController

  activate_menu :serviceadmin

  before_action :authorize_connect
  before_action :find_settings

  def edit; end

  def update
    attrs = params[:settings].slice( :app_gallery_enabled,
                                     :documentation_enabled,
                                     :documentation_public)

    if @settings.update(attrs)
      redirect_to edit_admin_site_documentation_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  def authorize_connect
    authorize! :manage, :connect_portal
  end

  def find_settings
    @settings = current_account.settings
  end

end
