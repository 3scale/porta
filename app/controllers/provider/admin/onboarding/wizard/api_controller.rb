class  Provider::Admin::Onboarding::Wizard::ApiController < Provider::Admin::Onboarding::Wizard::BaseController
  respond_to :html

  # add API
  def new
    @api = build_api_form
    track_step('new api')
  end

  def edit
    @api = build_api_form
    track_step('edit api')
  end

  def update
    @api = build_api_form

    if @api.validate(api_params) && @api.save
      redirect_to new_provider_admin_onboarding_wizard_request_path
    else
      render :new
    end
  end

  private

  def api_params
    params.require(:api)
  end

  def build_api_form
    ::Onboarding::ApiForm.new(service: service, proxy: proxy)
  end

  def service
    current_account.first_service!
  end

  def proxy
    service.proxy
  end
end
