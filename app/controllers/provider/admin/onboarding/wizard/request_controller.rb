class  Provider::Admin::Onboarding::Wizard::RequestController < Provider::Admin::Onboarding::Wizard::BaseController
  def new
    @request = build_request_form
    track_step('new request')
  end

  def update
    @request = build_request_form
    saved = @request.validate(request_params) && @request.save

    unless saved
      analytics.track('Validation Error', controller: controller_name, action: action_name)
      return render(action: :edit)
    end

    status = @request.test_api!
    success = status&.success?
    real_api = ApiClassificationService.test(@request.uri).real_api?

    if status
      unless success
        @error, @message = status.error
      end
    else
      @error = 'Server Error'
      @message = 'The gateway cannot be deployed at this moment, please try again in a couple of minutes.'
    end

    analytics.track('Onboarding Request',
                    success: success, error: @error, message: @message,
                    uri: @request.uri, real_api: real_api)

    if success
      redirect_to provider_admin_onboarding_wizard_request_path(response: status.body)
      onboarding.bubble_update('api')
    else
      render action: :edit
    end
  end

  # success (also shows response)
  def show
    @response = params[:response]
    @request = build_request_form
    track_step('show request')
  end

  def edit
    @request = build_request_form
    track_step('edit request')
  end

  protected

  def request_params
    params.require(:request)
  end

  def build_request_form
    ::Onboarding::RequestForm.new(proxy)
  end

  def proxy
    current_account.first_service!.proxy
  end
end
