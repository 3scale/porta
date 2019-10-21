# frozen_string_literal: true

class  Provider::Admin::Onboarding::Wizard::ProductController < Provider::Admin::Onboarding::Wizard::BaseController
  respond_to :html

  def new
    @service = service
    track_step('new product')
  end

  def edit
    @service = service
    track_step('edit product')
  end

  def update
    @service = service

    if @service.validate(service_params) && @service.update(service_params) && @service.save
      redirect_to new_provider_admin_onboarding_wizard_connect_path
    else
      render :new
    end
  end

  private

  def service_params
    params.require(:service)
  end
end
