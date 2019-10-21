# frozen_string_literal: true

class  Provider::Admin::Onboarding::Wizard::BackendApiController < Provider::Admin::Onboarding::Wizard::BaseController
  respond_to :html

  helper_method :example_backend_url

  def new
    @backend = backend_api
    track_step('new backend')
  end

  def update
    @backend = backend_api

    if @backend.validate(backend_api_params) && @backend.update(backend_api_params) && @backend.save
      redirect_to new_provider_admin_onboarding_wizard_product_path
    else
      render :new
    end
  end

  def example_backend_url
    ECHO_API_BACKEND
  end

  private

  ECHO_API_BACKEND = "https://#{BackendApi::ECHO_API_HOST}"

  def backend_api_params
    params.require(:backend_api).permit(:name, :private_endpoint)
  end

  def backend_api
    service.backend_apis.first!
  end
end
