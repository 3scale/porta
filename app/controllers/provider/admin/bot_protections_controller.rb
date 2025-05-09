# frozen_string_literal: true

class Provider::Admin::BotProtectionsController < Provider::Admin::BaseController

  activate_menu! :account, :integrate, :bot_protection

  before_action :find_settings

  def edit; end

  def update
    if @settings.update(params[:settings])
      redirect_to edit_provider_admin_bot_protection_url, success: t('.success')
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
