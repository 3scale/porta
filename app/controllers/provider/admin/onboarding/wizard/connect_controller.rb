# frozen_string_literal: true

class  Provider::Admin::Onboarding::Wizard::ConnectController < Provider::Admin::Onboarding::Wizard::BaseController

  def new
    @config = backend_api_config
    track_step('connect')
  end

  def update
    @config = backend_api_config

    if @config.validate(config_params) && @config.update(config_params) && @config.save
      redirect_to new_provider_admin_onboarding_wizard_request_path
    else
      render :new
    end
  end

  protected

  def backend_api_config
    service.backend_api_configs.first!
  end

  def config_params
    params.require(:backend_api_config).permit(:path)
  end
end
